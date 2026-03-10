-- Schema untuk SMK Kita
CREATE DATABASE IF NOT EXISTS smkkita CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smkkita;

SET NAMES utf8mb4;
SET time_zone = '+07:00';

-- Tabel otorisasi dasar
CREATE TABLE roles (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE users (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(120) NOT NULL,
  email          VARCHAR(120) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  phone          VARCHAR(30),
  photo_url      VARCHAR(255),
  role_id        INT NOT NULL,
  status         ENUM('active','inactive') DEFAULT 'active',
  last_login     DATETIME,
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_roles FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

-- Profil sekolah
CREATE TABLE school_profile (
  id              TINYINT PRIMARY KEY DEFAULT 1,
  name            VARCHAR(150) NOT NULL,
  npsn            VARCHAR(20),
  nss             VARCHAR(30),
  accreditation   VARCHAR(10),
  headmaster      VARCHAR(120),
  committee_head  VARCHAR(120),
  address         TEXT,
  phone           VARCHAR(30),
  email           VARCHAR(120),
  website         VARCHAR(120),
  about_html      TEXT,
  vision          TEXT,
  mission         TEXT,
  updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Akademik
CREATE TABLE departments (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  code          VARCHAR(10) NOT NULL UNIQUE,
  name          VARCHAR(120) NOT NULL,
  description   TEXT,
  logo_url      VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE teachers (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  nip          VARCHAR(30) UNIQUE,
  full_name    VARCHAR(120) NOT NULL,
  email        VARCHAR(120),
  phone        VARCHAR(30),
  specialization VARCHAR(120),
  department_id INT,
  photo_url    VARCHAR(255),
  hire_date    DATE,
  status       ENUM('active','inactive') DEFAULT 'active',
  CONSTRAINT fk_teachers_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE classes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50) NOT NULL,
  grade       ENUM('10','11','12') NOT NULL,
  department_id INT NOT NULL,
  homeroom_teacher_id INT,
  CONSTRAINT fk_classes_department FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT fk_classes_homeroom FOREIGN KEY (homeroom_teacher_id) REFERENCES teachers(id)
) ENGINE=InnoDB;

CREATE TABLE students (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nisn          VARCHAR(20) NOT NULL UNIQUE,
  full_name     VARCHAR(120) NOT NULL,
  gender        ENUM('L','P') NOT NULL,
  birth_place   VARCHAR(80),
  birth_date    DATE,
  address       TEXT,
  phone         VARCHAR(30),
  email         VARCHAR(120),
  enrollment_year YEAR NOT NULL,
  department_id INT NOT NULL,
  class_id      INT,
  guardian_name VARCHAR(120),
  guardian_phone VARCHAR(30),
  status        ENUM('active','graduated','transfer','dropout') DEFAULT 'active',
  CONSTRAINT fk_students_department FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT fk_students_class FOREIGN KEY (class_id) REFERENCES classes(id)
) ENGINE=InnoDB;

CREATE TABLE subjects (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  code          VARCHAR(15) NOT NULL UNIQUE,
  name          VARCHAR(120) NOT NULL,
  description   TEXT,
  department_id INT,
  grade         ENUM('10','11','12'),
  CONSTRAINT fk_subjects_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE teaching_assignments (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  subject_id    INT NOT NULL,
  teacher_id    INT NOT NULL,
  class_id      INT NOT NULL,
  academic_year VARCHAR(9) NOT NULL, -- contoh 2024/2025
  semester      ENUM('ganjil','genap') NOT NULL,
  CONSTRAINT fk_assign_subject FOREIGN KEY (subject_id) REFERENCES subjects(id),
  CONSTRAINT fk_assign_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id),
  CONSTRAINT fk_assign_class FOREIGN KEY (class_id) REFERENCES classes(id)
) ENGINE=InnoDB;

CREATE TABLE schedules (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  class_id     INT NOT NULL,
  subject_id   INT NOT NULL,
  teacher_id   INT NOT NULL,
  day          ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu') NOT NULL,
  start_time   TIME NOT NULL,
  end_time     TIME NOT NULL,
  room         VARCHAR(50),
  CONSTRAINT fk_sched_class FOREIGN KEY (class_id) REFERENCES classes(id),
  CONSTRAINT fk_sched_subject FOREIGN KEY (subject_id) REFERENCES subjects(id),
  CONSTRAINT fk_sched_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id)
) ENGINE=InnoDB;

-- Ekstrakurikuler
CREATE TABLE extracurriculars (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(120) NOT NULL,
  description     TEXT,
  coach_teacher_id INT,
  meeting_day     ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'),
  start_time      TIME,
  end_time        TIME,
  location        VARCHAR(120),
  icon_url        VARCHAR(255),
  CONSTRAINT fk_ekskul_coach FOREIGN KEY (coach_teacher_id) REFERENCES teachers(id)
) ENGINE=InnoDB;

CREATE TABLE extracurricular_members (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  extracurricular_id INT NOT NULL,
  student_id        INT NOT NULL,
  position          ENUM('anggota','ketua','wakil','sekretaris','bendahara') DEFAULT 'anggota',
  joined_at         DATE DEFAULT CURRENT_DATE,
  CONSTRAINT fk_member_ekskul FOREIGN KEY (extracurricular_id) REFERENCES extracurriculars(id),
  CONSTRAINT fk_member_student FOREIGN KEY (student_id) REFERENCES students(id),
  UNIQUE (extracurricular_id, student_id)
) ENGINE=InnoDB;

-- Konten situs
CREATE TABLE news (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(200) NOT NULL,
  slug         VARCHAR(220) NOT NULL UNIQUE,
  excerpt      TEXT,
  content      MEDIUMTEXT,
  cover_url    VARCHAR(255),
  published_at DATETIME,
  author_id    INT,
  is_published TINYINT(1) DEFAULT 0,
  CONSTRAINT fk_news_author FOREIGN KEY (author_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE events (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(200) NOT NULL,
  slug         VARCHAR(220) NOT NULL UNIQUE,
  category     VARCHAR(80),
  start_date   DATETIME NOT NULL,
  end_date     DATETIME,
  location     VARCHAR(150),
  description  MEDIUMTEXT,
  banner_url   VARCHAR(255),
  is_published TINYINT(1) DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE achievements (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  title            VARCHAR(200) NOT NULL,
  achievement_date DATE,
  level            ENUM('Sekolah','Kabupaten','Provinsi','Nasional','Internasional'),
  organizer        VARCHAR(150),
  description      TEXT,
  team_name        VARCHAR(120),
  photo_url        VARCHAR(255),
  category         VARCHAR(80),
  student_id       INT,
  extracurricular_id INT,
  CONSTRAINT fk_ach_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_ach_ekskul FOREIGN KEY (extracurricular_id) REFERENCES extracurriculars(id)
) ENGINE=InnoDB;

CREATE TABLE galleries (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  description TEXT,
  media_url   VARCHAR(255) NOT NULL,
  media_type  ENUM('image','video') DEFAULT 'image',
  album       VARCHAR(80),
  taken_at    DATE,
  is_featured TINYINT(1) DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE facilities (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(120) NOT NULL,
  category    VARCHAR(80),
  description TEXT,
  photo_url   VARCHAR(255),
  quantity    INT DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE documents (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  file_url    VARCHAR(255) NOT NULL,
  category    VARCHAR(80),
  published_at DATETIME,
  description TEXT
) ENGINE=InnoDB;

CREATE TABLE contact_messages (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(120) NOT NULL,
  email       VARCHAR(120) NOT NULL,
  phone       VARCHAR(30),
  message     TEXT NOT NULL,
  status      ENUM('baru','dibaca','direspon') DEFAULT 'baru',
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE testimonials (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(120) NOT NULL,
  role        VARCHAR(80),
  message     TEXT NOT NULL,
  relation    ENUM('alumni','orangtua','industri','guru','siswa') DEFAULT 'alumni',
  photo_url   VARCHAR(255),
  published_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE admissions (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  registration_no VARCHAR(30) NOT NULL UNIQUE,
  full_name      VARCHAR(120) NOT NULL,
  nisn           VARCHAR(20),
  gender         ENUM('L','P') NOT NULL,
  birth_place    VARCHAR(80),
  birth_date     DATE,
  address        TEXT,
  phone          VARCHAR(30),
  email          VARCHAR(120),
  previous_school VARCHAR(150),
  department_choice1 INT,
  department_choice2 INT,
  status         ENUM('baru','diverifikasi','diterima','ditolak') DEFAULT 'baru',
  registered_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_adm_choice1 FOREIGN KEY (department_choice1) REFERENCES departments(id),
  CONSTRAINT fk_adm_choice2 FOREIGN KEY (department_choice2) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE academic_calendar (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  start_date  DATE NOT NULL,
  end_date    DATE,
  category    ENUM('libur','ujian','rapor','ppdb','lainnya') DEFAULT 'lainnya',
  description TEXT
) ENGINE=InnoDB;

-- Data awal minimal
INSERT INTO roles (name, description) VALUES
 ('admin','Akses penuh untuk mengelola konten dan data'),
 ('staff','Staf tata usaha/guru untuk input data'),
 ('student','Akun siswa untuk melihat jadwal/nilai');

INSERT INTO users (name, email, password_hash, role_id, status)
VALUES ('Administrator','admin@smkkita.sch.id','$2y$10$isi_hash_bcrypt_di_sini',1,'active');

INSERT INTO school_profile (id, name, npsn, nss, accreditation, headmaster, committee_head, address, phone, email, website, about_html, vision, mission)
VALUES (1,
 'SMK Negeri 1 Cikarang Selatan',
 '20238032',
 '401.0222.19.001',
 'A (Sangat Baik)',
 'Cucu Sudrajat, S.Pd., M.M.',
 'H. Dedi Setiadi',
 'Jl. Raya Serang–Cibarusah, Sukadami, Cikarang Selatan, Kab. Bekasi',
 '(021) 8903230',
 'info@smkkita.sch.id',
 'https://smkkita.sch.id',
 'Profil singkat sekolah dan sejarah berdiri.',
 'Unggul, Berkarakter, Profesional',
 '1. Menyelenggarakan pendidikan kejuruan yang relevan dengan dunia industri\n2. Membentuk peserta didik berkarakter dan berdaya saing'
);

INSERT INTO departments (code, name, description)
VALUES ('RPL','Rekayasa Perangkat Lunak','Pengembangan perangkat lunak dan sistem'),
       ('TJKT','Teknik Jaringan Komputer & Telekomunikasi','Jaringan, server, dan infrastruktur'),
       ('TEI','Teknik Elektronika Industri','Elektronika dan otomasi industri'),
       ('TM','Teknik Mesin','Produksi dan perawatan mesin'),
       ('AKL','Akuntansi & Keuangan Lembaga','Akuntansi dan keuangan');

INSERT INTO extracurriculars (name, description, meeting_day, start_time, end_time, location)
VALUES ('Paskibra','Latihan kedisiplinan dan baris-berbaris','Jumat','15:30','17:30','Lapangan'),
       ('Pramuka','Pengembangan karakter dan kepemimpinan','Sabtu','08:00','11:00','Aula'),
       ('Rohis','Kegiatan rohani Islam','Kamis','15:30','17:00','Musholla'),
       ('Futsal','Pembinaan olahraga futsal','Rabu','15:30','17:30','Gor'),
       ('PMR','Palang Merah Remaja','Selasa','15:30','17:00','UKS');

-- Index rekomendasi
CREATE INDEX idx_students_name ON students(full_name);
CREATE INDEX idx_teachers_name ON teachers(full_name);
CREATE INDEX idx_news_published ON news(published_at);
CREATE INDEX idx_events_start ON events(start_date);
CREATE INDEX idx_sched_class_day ON schedules(class_id, day);

