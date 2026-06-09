# Modelo Conceitual

## Entidades
1. **Artist**
2. **Genre**
3. **Album**
4. **Music**
5. **User**
6. **Playlist**
7. **AuditLog**
8. **PlaylistItem**

## Atributos
- **Artist**  
  - spotify_id (PK)  
  - name  
  - popularity  

- **Genre**  
  - genre_id (PK)  
  - name  

- **Album**  
  - album_id (PK)  
  - title  
  - release_date  
  - release_type  

- **Music**  
  - music_id (PK)  
  - title  
  - duration_ms  
  - energy  
  - valence  
  - danceability  
  - bpm  
  - album_id (FK)  

- **User**  
  - user_id (PK)  
  - name  
  - email  
  - registration_date  

- **Playlist**  
  - playlist_id (PK)  
  - spotify_link  
  - created_at  
  - user_id (FK)  

- **AuditLog**  
  - log_id (PK)  
  - prompt_text  
  - parameters  
  - playlist_id (FK)  

- **PlaylistItem**  
  - playlist_item_id (PK)  
  - position  
  - playlist_id (FK)  
  - music_id (FK)  

## Relacionamentos
- **Artist** (1) : **Genre** (N) → N:N  
- **Artist** (1) : **Album** (N) → 1:N  
- **Album** (1) : **Music** (N) → 1:N  
- **User** (1) : **Playlist** (N) → 1:N  
- **Playlist** (1) : **AuditLog** (1) → 1:1  
- **Playlist** (1) : **PlaylistItem** (N) → 1:N  
- **Music** (1) : **PlaylistItem** (N) → 1:N