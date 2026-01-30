import csv
import oracledb
from getpass import getpass

# Konfiguracja
USERNAME = "grabowskak"
DSN = "213.184.8.44:1521/orcl"

# Połączenie z bazą danych
def connect():
    password = getpass("Oracle password: ")
    return oracledb.connect(user=USERNAME,password=password,dsn=DSN)
    print("Connected succesfully")

# Logowanie informacji do tabeli import_log
def log(cur, table_name, file_name, raw_data, status, message):
    # instrukcja sql
    sql = """
    INSERT INTO import_log (table_name, file_name, raw_data, status, message)
    VALUES (:1, :2, :3, :4, :5) 
    """
    cur.execute(sql, (table_name, file_name, raw_data, status, message))

# Ładowanie autorów
def load_authors(cur):
    sql = """
    INSERT INTO authors (author_id, first_name, last_name, birth_year, death_year)
    VALUES (:1, :2, :3, :4, :5)
    """
    with open("data/authors.csv", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                # konwersja lat na dane liczbowe
                birth = int(row["birth_year"]) if row["birth_year"] else None
                death = int(row["death_year"]) if row["death_year"] else None

                if birth and death and death <= birth:
                    raise ValueError("death_year must be greater than birth_year")
                # wstawienie poprawnych rekordow do bazy
                cur.execute(sql, (
                    int(row["author_id"]),
                    row["first_name"],
                    row["last_name"],
                    birth,
                    death
                ))
                log(cur, "AUTHORS", "data/authors.csv", str(row), "SUCCESS", "OK")
            except Exception as e:
                # zapis informacji o bledzie do tabeli logów
                log(cur, "AUTHORS", "data/authors.csv", str(row), "ERROR", str(e))

# Ładowanie kategorii
def load_categories(cur):
    sql = """
    INSERT INTO categories (category_id, name, description)
    VALUES (:1, :2, :3)
    """
    with open("data/categories.csv", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                if not row["name"]:
                    raise ValueError("Category name cannot be empty")
                cur.execute(sql, (
                    int(row["category_id"]),
                    row["name"],
                    row["description"]
                ))
                log(cur, "CATEGORIES", "data/categories.csv", str(row), "SUCCESS", "OK")
            except Exception as e:
                log(cur, "CATEGORIES", "data/categories.csv", str(row), "ERROR", str(e))

# Ładowanie książek
def load_books(cur):
    sql = """
    INSERT INTO books
    (title, isbn, author_id, category_id, price, stock_quantity, year_of_release)
    VALUES (:1, :2, :3, :4, :5, :6, :7)
    """
    with open("data/books.csv", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                price = float(row["price"])
                stock = int(row["stock_quantity"])
                year = int(row["year_of_release"]) if row["year_of_release"] else None
                author_id = int(row["author_id"])
                category_id = int(row["category_id"]) if row["category_id"] else None

                if price <= 0:
                    raise ValueError("Price must be > 0")
                if stock < 0:
                    raise ValueError("Stock must be >= 0")

                cur.execute(sql, (
                    row["title"],
                    row["isbn"],
                    author_id,
                    category_id,
                    price,
                    stock,
                    year
                ))
                log(cur, "BOOKS", "data/books.csv", str(row), "SUCCESS", "OK")
            except Exception as e:
                log(cur, "BOOKS", "data/books.csv", str(row), "ERROR", str(e))


con = connect()
cur = con.cursor() # kursor bazy danych do wykonywania SQL

load_authors(cur)
load_categories(cur)
load_books(cur)

con.commit()
cur.close()
con.close()
print("Import finished!")
