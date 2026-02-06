
CREATE ROLE tenant_user LOGIN PASSWORD 'tenant123$';
GRANT ALL PRIVILEGES ON DATABASE salesdb TO tenant_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO tenant_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tenant_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO tenant_user;

SELECT rolname, rolsuper, rolbypassrls
FROM pg_roles
WHERE rolname = 'tenant_user';

SET ROLE myuser;
SET ROLE tenant_user;



