-- Create item chloride conversions table and load selected conversions

DROP TABLE IF EXISTS itemclconversions CASCADE;
CREATE TABLE itemclconversions
(
  itemid INT NOT NULL,
  uom VARCHAR(30),
  meq_multiplier DOUBLE PRECISION
);

\copy itemclconversions FROM 'chloride_conversions.csv' DELIMITER ',' CSV HEADER NULL '';
