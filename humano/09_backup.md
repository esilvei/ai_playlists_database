pg_restore -U postgres -h localhost -p 5432 -d banco_vazio -1 /caminho/para/backup_streaming.dump

wal_level = replica               # Permite que o log guarde informações detalhadas
archive_mode = on                 # Liga o modo de arquivamento
#No Linux:
archive_command = 'cp %p /caminho/pasta_segura_wal/%f' 
#No Windows:
#Archive_command = 'copy "%p" "C:\pasta_segura_wal\%f"'

pg_basebackup -U postgres -D /caminho/pasta_backup_base -Ft -z -P

#Ensina o banco de onde buscar os ficheiros WAL guardados
restore_command = 'cp /caminho/pasta_segura_wal/%f %p'

#Define a data e hora EXATA para onde quer voltar
recovery_target_time = '2026-06-16 14:34:00' 