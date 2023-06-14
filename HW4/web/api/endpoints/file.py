import schemas
from fastapi import APIRouter, Response, UploadFile, status, HTTPException
from storage import storage
from config import settings
import urllib.parse
router = APIRouter()

# filename_list = {}


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=schemas.File,
    name="file:create_file",
)
async def create_file(file: UploadFile) -> schemas.File:
    # raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Missing 'name' field")
    read_bytes = await file.read()
    if len(read_bytes) > settings.MAX_SIZE:
        raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="File too large")
    if await storage.file_integrity(file.filename):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="File already exists")
    file.file.seek(0)
    return await storage.create_file(file)


@router.get("/", status_code=status.HTTP_200_OK, name="file:retrieve_file")
async def retrieve_file(filename: str) -> Response:
    # TODO: Add headers to ensure the filename is displayed correctly
    #       You should also ensure that enables the judge to download files directly
    # return_filename = urllib.parse.quote(filename)
    print(filename)
    if await storage.file_integrity(filename) == False:
        await storage.delete_file(filename)
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")

    return_filename = urllib.parse.quote(filename)
    return Response(
        await storage.retrieve_file(filename),
        media_type="application/octet-stream",
        headers={"Content-Disposition": f'attachment; filename={return_filename}'},
    )


@router.put("/", status_code=status.HTTP_200_OK, name="file:update_file")
async def update_file(file: UploadFile) -> schemas.File:
    if await storage.file_integrity(file.filename) == False:
        await storage.delete_file(file.filename)
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    read_bytes = await file.read()
    if len(read_bytes) > settings.MAX_SIZE:
        raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail="File too large")
    file.file.seek(0)
    return await storage.update_file(file)


@router.delete("/", status_code=status.HTTP_200_OK, name="file:delete_file")
async def delete_file(filename: str) -> str:
    if await storage.file_integrity(filename) == False:
        await storage.delete_file(filename)
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    await storage.delete_file(filename)
    return schemas.Msg(detail="File deleted")
