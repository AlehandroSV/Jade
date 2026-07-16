return {
    -- Errors
    not_configured = "Jade não configurado. Chame jade.configure() primeiro.",
    driver_not_found = "Driver desconhecido: %s",
    table_not_found = "Tabela não encontrada: %s",
    column_not_found = "Coluna não encontrada: %s",
    migration_failed = "Falha na migração: %s",
    rollback_failed = "Falha no rollback: %s",
    transaction_not_active = "Nenhuma transação ativa",
    transaction_already_active = "Transação já ativa",
    cannot_update_no_id = "Não é possível atualizar instância sem id",
    cannot_delete_no_id = "Não é possível deletar instância sem id",
    cannot_refresh_no_id = "Não é possível atualizar instância sem id",
    failed_to_connect = "Falha ao conectar em %s",
    failed_to_load_config = "Falha ao carregar config: %s",
    failed_to_create_migration = "Falha ao criar arquivo de migração: %s",

    -- Migration
    no_pending_migrations = "Nenhuma migração pendente",
    applying_migration = "Aplicando: %s",
    applied_migration = "  Aplicada: %s",
    failed_migration = "  Falhou: %s",
    rolling_back = "Revertendo: %s",
    rolled_back = "  Revertida: %s",
    failed_rollback = "  Falhou: %s",
    migration_complete = "Todas as migrações aplicadas!",
    rollback_complete = "Rollback concluído!",

    -- Types
    type_string = "Texto",
    type_text = "Texto Longo",
    type_integer = "Inteiro",
    type_bigint = "Inteiro Grande",
    type_float = "Decimal",
    type_decimal = "Decimal Preciso",
    type_boolean = "Booleano",
    type_timestamp = "Data/Hora",
    type_date = "Data",
    type_uuid = "UUID",
    type_json = "JSON",

    -- Relations
    belongs_to = "pertence a",
    has_many = "tem vários",
    has_one = "tem um",
    foreign_key = "chave estrangeira",

    -- Soft delete
    soft_deleted = "Deletado",
    restored = "Restaurado",
    force_deleted = "Deletado permanentemente",
}
