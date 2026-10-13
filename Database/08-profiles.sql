-- 1. Perfiles (1 a 1 con users)
CREATE TABLE IF NOT EXISTS profiles (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    bio TEXT,
    avatar_url VARCHAR(255),
    location VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 2. Configuración de usuario (1 a 1 con users)
CREATE TABLE IF NOT EXISTS user_settings (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    language VARCHAR(10) DEFAULT 'es',
    theme VARCHAR(20) DEFAULT 'light',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_settings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Privacidad (1 a 1 con users)
CREATE TABLE IF NOT EXISTS user_privacy (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    profile_visibility VARCHAR(20) DEFAULT 'public',
    show_online_status BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_privacy_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Bloqueos de usuario (N a N entre usuarios)
CREATE TABLE IF NOT EXISTS user_blocks (
    id SERIAL PRIMARY KEY,
    blocker_id INT NOT NULL,
    blocked_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_blocker FOREIGN KEY (blocker_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_blocked FOREIGN KEY (blocked_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_block UNIQUE (blocker_id, blocked_id)
);



-- 1. Perfiles
INSERT INTO profiles (user_id, bio, avatar_url, location, website)
SELECT
    id AS user_id,
    'Hola, soy el usuario con ID ' || id || ' y este es mi perfil en Dren.' AS bio,
    'https://cdn.dren.com/avatars/user_' || id || '.jpg' AS avatar_url,
    'Oaxaca, México' AS location,
    'https://user' || id || '.dev' AS website
FROM users;

-- 2. Configuraciones
INSERT INTO user_settings (user_id, language, theme, notifications_enabled)
SELECT
    id AS user_id,
    CASE WHEN id % 2 = 0 THEN 'es' ELSE 'en' END AS language,
    CASE WHEN id % 3 = 0 THEN 'dark' ELSE 'light' END AS theme,
    TRUE AS notifications_enabled
FROM users;

-- 3. Privacidad
INSERT INTO user_privacy (user_id, profile_visibility, show_online_status)
SELECT
    id AS user_id,
    'public' AS profile_visibility,
    TRUE AS show_online_status
FROM users;




EXPLAIN ANALYZE SELECT * FROM profiles WHERE user_id = 45;

-- Índice único para buscar rápidamente el perfil de un usuario por su ID
CREATE UNIQUE INDEX idx_profiles_user ON profiles(user_id);

-- Índices para la tabla de bloqueos (quién bloqueó a quién)
CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_user_blocks_blocked ON user_blocks(blocked_id);



SELECT
    u.id AS usuario_id,
    u.email AS correo,
    p.bio,
    p.location,
    s.theme,
    s.language,
    pr.profile_visibility
FROM users u
JOIN profiles p ON u.id = p.user_id
JOIN user_settings s ON u.id = s.user_id
JOIN user_privacy pr ON u.id = pr.user_id
LIMIT 10;