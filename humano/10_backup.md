-- ============================================================================
-- 1. ESTRATÉGIA DE BACKUP E RECUPERAÇÃO (PITR)
-- ============================================================================

-- A. BACKUP LÓGICO (Ideal para migrações e auditoria de tabelas específicas)
-- pg_dump -U usuario -h localhost -d nome_do_banco -F c -f backup_curadoria.dump

-- B. BACKUP FÍSICO / BASE (Para recuperação total do cluster)
-- Executado no terminal:
-- pg_basebackup -U postgres -D /caminho/pasta_backup_base -Ft -z -P

-- C. CONFIGURAÇÃO DO POSTGRESQL (postgresql.conf)
-- Para permitir a recuperação em um ponto específico do tempo (PITR):
-- wal_level = replica
-- archive_mode = on
-- archive_command = 'cp %p /caminho/pasta_segura_wal/%f' 

-- D. CONFIGURAÇÃO DE RECUPERAÇÃO (recovery.conf ou recovery.signal em versões recentes)
-- restore_command = 'cp /caminho/pasta_segura_wal/%f %p'
-- recovery_target_time = '2026-06-16 14:34:00' 