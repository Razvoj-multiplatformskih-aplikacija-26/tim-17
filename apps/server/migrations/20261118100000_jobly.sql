-- migrate:up
CREATE TABLE users (
  id text PRIMARY KEY,
  username text NOT NULL UNIQUE,
  password_hash text,
  role text NOT NULL CHECK (role IN ('student', 'employer', 'staff')),
  first_name text NOT NULL,
  last_name text NOT NULL,
  faculty text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT ''
);

CREATE TABLE job_postings (
  id text PRIMARY KEY,
  employer_id text NOT NULL,
  employer_name text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  city text NOT NULL,
  category text NOT NULL CHECK (category IN ('hospitality', 'retail', 'warehouse', 'promotion', 'office', 'delivery', 'events', 'it')),
  shift text NOT NULL CHECK (shift IN ('morning', 'afternoon', 'night', 'weekend', 'flexible')),
  pay_type text NOT NULL CHECK (pay_type IN ('daily', 'hourly', 'perTask')),
  hourly_rate int NOT NULL CHECK (hourly_rate >= 0),
  required_workers int NOT NULL CHECK (required_workers > 0),
  starts_at timestamptz NOT NULL,
  posted_at timestamptz NOT NULL,
  hours_per_shift int NOT NULL CHECK (hours_per_shift > 0),
  status text NOT NULL CHECK (status IN ('open', 'closed'))
);

CREATE TABLE applications (
  id text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  job_id text NOT NULL REFERENCES job_postings (id),
  student_id text NOT NULL REFERENCES users (id),
  status text NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'completed', 'withdrawn')),
  applied_at timestamptz NOT NULL,
  letter text
);

CREATE UNIQUE INDEX applications_one_per_job ON applications (student_id, job_id) WHERE status <> 'withdrawn';
CREATE INDEX applications_by_student ON applications (student_id);
CREATE INDEX applications_by_job ON applications (job_id);

-- migrate:down
DROP TABLE applications;
DROP TABLE job_postings;
DROP TABLE users;
