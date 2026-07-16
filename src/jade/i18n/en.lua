return {
    -- Errors
    not_configured = "Jade not configured. Call jade.configure() first.",
    driver_not_found = "Unknown driver: %s",
    table_not_found = "Table not found: %s",
    column_not_found = "Column not found: %s",
    migration_failed = "Migration failed: %s",
    rollback_failed = "Rollback failed: %s",
    transaction_not_active = "No active transaction",
    transaction_already_active = "Transaction already active",
    cannot_update_no_id = "Cannot update instance without id",
    cannot_delete_no_id = "Cannot delete instance without id",
    cannot_refresh_no_id = "Cannot refresh instance without id",
    failed_to_connect = "Failed to connect to %s",
    failed_to_load_config = "Failed to load config: %s",
    failed_to_create_migration = "Failed to create migration file: %s",

    -- Migration
    no_pending_migrations = "No pending migrations",
    applying_migration = "Applying: %s",
    applied_migration = "  Applied: %s",
    failed_migration = "  Failed: %s",
    rolling_back = "Rolling back: %s",
    rolled_back = "  Rolled back: %s",
    failed_rollback = "  Failed: %s",
    migration_complete = "All migrations applied!",
    rollback_complete = "Rollback complete!",

    -- Types
    type_string = "String",
    type_text = "Text",
    type_integer = "Integer",
    type_bigint = "BigInt",
    type_float = "Float",
    type_decimal = "Decimal",
    type_boolean = "Boolean",
    type_timestamp = "Timestamp",
    type_date = "Date",
    type_uuid = "UUID",
    type_json = "JSON",

    -- Relations
    belongs_to = "belongs to",
    has_many = "has many",
    has_one = "has one",
    foreign_key = "foreign key",

    -- Soft delete
    soft_deleted = "Soft deleted",
    restored = "Restored",
    force_deleted = "Force deleted",
}
