CREATE TABLE driver (
  id BIGINT PRIMARY KEY,
  coordinate BLOB,
  date_coordinate_updated TIMESTAMP,
  date_created TIMESTAMP,
  deleted BOOLEAN,
  online_status VARCHAR(255),
  password VARCHAR(255),
  username VARCHAR(255)
);

CREATE TABLE car (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  license_plate VARCHAR(255),
  seat_count INT,
  convertible BOOLEAN,
  rating INT,
  engine_type VARCHAR(50),
  manufacturer VARCHAR(255),
  date_created TIMESTAMP,
  deleted BOOLEAN
);
