import logging
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.services.ai.video import VideoGenerationServiceFactory

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/generate")
async def generate_video(
    image: UploadFile = File(...),
    prompt: str = Form(...),
    service_type: str = Form("luma_dream_machine"),
    db: Session = Depends(get_db)
):
    """
    Generate a video from an image and prompt using the specified video generation service.
    
    Args:
        image: Image file to animate
        prompt: Text prompt describing the desired video/animation
        service_type: Type of video generation service to use
                     (luma_dream_machine, stable_video_diffusion, animatediff)
        db: Database session
        
    Returns:
        Video file (MP4 format) as bytes
    """
    logger.info(f"Video generation request: service={service_type}, prompt={prompt[:50]}...")
    
    # Validate service type
    if not VideoGenerationServiceFactory.is_service_available(service_type):
        available = ", ".join(VideoGenerationServiceFactory.get_available_services())
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid service type: {service_type}. Available: {available}"
        )
    
    # Validate prompt
    if not prompt or not prompt.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Prompt cannot be empty"
        )
    
    try:
        # Read image bytes
        image_bytes = await image.read()
        
        logger.info(f"Received image: filename={image.filename}, content_type={image.content_type}, size={len(image_bytes)} bytes")
        
        # Validate image - check content type first, then magic bytes if needed
        is_valid_image = False
        
        if image.content_type and image.content_type.startswith('image/'):
            # Content type is valid
            is_valid_image = True
            logger.info("Image validated by content_type")
        else:
            # Content type is missing or invalid, check magic bytes (file signature)
            logger.info(f"Content type missing or invalid ({image.content_type}), checking magic bytes...")
            
            if len(image_bytes) < 4:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="File is too small to be a valid image"
                )
            
            # Check magic bytes for common image formats
            is_jpeg = image_bytes[:2] == b'\xff\xd8'
            is_png = len(image_bytes) >= 8 and image_bytes[:8] == b'\x89PNG\r\n\x1a\n'
            is_gif = len(image_bytes) >= 6 and image_bytes[:6] in [b'GIF87a', b'GIF89a']
            is_webp = len(image_bytes) >= 12 and image_bytes[:4] == b'RIFF' and image_bytes[8:12] == b'WEBP'
            
            is_valid_image = is_jpeg or is_png or is_gif or is_webp
            
            logger.info(f"Magic bytes check: JPEG={is_jpeg}, PNG={is_png}, GIF={is_gif}, WebP={is_webp}, Valid={is_valid_image}")
            logger.info(f"First 12 bytes (hex): {image_bytes[:12].hex()}")
        
        if not is_valid_image:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File must be an image (JPEG, PNG, GIF, or WebP). Received content_type: {image.content_type or 'none'}, filename: {image.filename or 'unknown'}"
            )
        
        # Create video generation service
        video_service = VideoGenerationServiceFactory.create_service(
            service_type=service_type
        )
        
        # Generate video
        logger.info(f"Generating video with {service_type}...")
        video_bytes = await video_service.generate_video(
            image=image_bytes,
            prompt=prompt.strip()
        )
        
        logger.info(f"Video generated successfully: {len(video_bytes)} bytes")
        
        # Return video as response
        from fastapi.responses import Response
        return Response(
            content=video_bytes,
            media_type="video/mp4",
            headers={
                "Content-Disposition": f'attachment; filename="generated_video.mp4"'
            }
        )
        
    except ValueError as e:
        error_msg = str(e)
        logger.error(f"Validation error: {error_msg}")
        
        # Provide more helpful error messages for common issues
        if "API_KEY" in error_msg or "API key" in error_msg.lower():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"{error_msg}. Please configure the API key in your environment variables or .env file."
            )
        
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_msg
        )
    except Exception as e:
        logger.error(f"Failed to generate video: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Video generation failed: {str(e)}"
        )

