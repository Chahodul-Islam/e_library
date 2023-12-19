CREATE TABLE if not exists users(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL CHECK(POSITION('@' IN email) > 0),
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL CHECK (length(password) >= 8)
);

CREATE TABLE if not exists publishers(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contract VARCHAR(255)
);
CREATE TABLE if not exists categories(
  id serial PRIMARY KEY,
  genre_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE if not exists books(
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(13) NOT NULL UNIQUE CHECK (length(isbn) = 13),
  publisher_id SERIAL NOT NULL REFERENCES publishers(id),
  pub_date DATE NOT NULL,
  genre_id INTEGER NOT NULL REFERENCES categories(id),
  availability BOOLEAN NOT NULL
);

CREATE TABLE if not exists Reviews(
  id serial primary key,
  userid INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  book_id serial NOT NULL REFERENCES books(id) on delete cascade,
  review_text TEXT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5)
);