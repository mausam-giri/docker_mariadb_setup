#!/bin/bash

# Load environment variables
source .env

echo "🚀 Starting database import..."
echo "📊 Database: ${MYSQL_DATABASE}"
echo "⚠️  Foreign key checks disabled for import"
echo "⏳ This may take a while for large databases..."
echo ""

(
  echo "SET FOREIGN_KEY_CHECKS=0;"
  echo "SET UNIQUE_CHECKS=0;"
  echo "SET AUTOCOMMIT=0;"
  echo "SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';"
  cat dumps/_xyz.sql
  echo ""
  echo "COMMIT;"
  echo "SET FOREIGN_KEY_CHECKS=1;"
  echo "SET UNIQUE_CHECKS=1;"
) | docker exec -i mysql_db mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}"

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Import completed successfully!"
  echo "🔍 Verifying tables..."
  TABLE_COUNT=$(docker exec mysql_db mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" -e "SHOW TABLES;" 2>/dev/null | tail -n +2 | wc -l)
  echo "   Tables imported: $TABLE_COUNT"
else
  echo ""
  echo "❌ Import failed. Check the errors above."
  exit 1
fi
