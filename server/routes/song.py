import uuid
from fastapi import APIRouter, Depends, File, UploadFile, Form

from database import get_db
from middleware.auth_middleware import auth_middleware

from sqlalchemy.orm import Session

import cloudinary
import cloudinary.uploader


from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong
from models.favorite import Favorite

from sqlalchemy.orm import joinedload

router = APIRouter()

cloudinary.config( 
     cloud_name="dpqpnvn8u",
    api_key="547413896474848",
    api_secret = "_2u7kTvbnTTxOixZ0C_S4BN0SAs",
    secure=True
)


@router.post('/upload',status_code=201)
def upload_song(
    song:UploadFile=File(...),
    thumbnail:UploadFile=File(...),
    artist:str=Form(...),
    song_name:str=Form(...),
    hex_code:str=Form(...),
    db:Session=Depends(get_db),
    auth_dict=Depends(auth_middleware)
    ):
    song_id=str(uuid.uuid4())
    song_res=cloudinary.uploader.upload(file=song.file,resource_type='auto',folder=f'songs/{song_id}')
    # print(song_res)

    thumb_res=cloudinary.uploader.upload(file=thumbnail.file,resource_type='image',folder=f'songs/{song_id}')
    # print(thumb_res)

    new_song=Song(
        id=song_id,
        song_name=song_name,
        thumbnail_url=thumb_res['url'],
        artist=artist,
        hex_code=hex_code,
        song_url=song_res['url'],    
    )
    #store all data into postgress
    db.add(new_song)
    db.commit()
    db.refresh(new_song)

    return new_song


@router.get('/list')
def list_songs(db:Session=Depends(get_db),auth_details=Depends(auth_middleware)):
    songs=db.query(Song).all()
    return songs


@router.post('/favorite')
def fav_song(
    song:FavoriteSong, 
    db:Session=Depends(get_db),
    auth_details=Depends(auth_middleware)):
    user_id=auth_details['uid']
    fav_song=db.query(Favorite).filter(Favorite.song_id==song.song_id,Favorite.user_id==user_id).first()
    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message':False}
    else:
        new_fav=Favorite(id=str(uuid.uuid4()),song_id=song.song_id,user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {'message':True}


@router.get('/list/favorites')
def get_all_favorites(
    db:Session=Depends(get_db),
    auth_details=Depends(auth_middleware)
    ):
    user_id=auth_details['uid']
    songs=db.query(Favorite).filter(Favorite.user_id==user_id).options(
        joinedload(Favorite.song)
    ).all()
    return songs

    


    