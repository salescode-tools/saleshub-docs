DO $$
BEGIN
  -- Schema usage
  EXECUTE 'GRANT USAGE ON SCHEMA public TO tenant_user';

  -- All current tables
  EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tenant_user';

  -- All current sequences
  EXECUTE 'GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO tenant_user';

  -- Future tables
  EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public
           GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO tenant_user';

  -- Future sequences
  EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA public
           GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO tenant_user';

  -- Allow tenant registration function
  EXECUTE 'GRANT EXECUTE ON FUNCTION register_tenant_admin(
             varchar, text, text, text, text, text, text, text
           ) TO tenant_user';
END$$;