import os
from fastapi improt FastAPI
from sqlalchemy import create_engine
import psycopg2 # or your preferred DB driver
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
db_pass = os.getenv("DB_PASSWORD")

app = FastAPI(title="Hello Bank")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

account = {"ACC001" : 1000.00, "ACC002" : 500.00}

class TransferRequest(BaseModel):
    from_acc: str
    to_acc: str
    amount: float

# 1. Get database credentials from environment variables (READ FROM KUBERNETES ENV VARIABLES)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "hellobank")
DB_USER = os.getenv("DB_USER", "bankadmin")
DB_PASS = os.getenv("DB_PASSWORD") # This matches the name in deployment.yaml

# 2. CREATE CONNECTION STRING
# Format: postgresql://user:password@host:port/dbname
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:5432/{DB_NAME}"

# 3. INITIALIZE DATABASE ENGINE
# The app will now use the secret password fetched from K8s at runtime
engine = create_engine(DATABASE_URL)

@app.get("/db-check")
def check_db():
    try:
        # Use the variables to connect
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        return {"status": "Connected to Database successfully!"}
    except Exception as e:
        return {"status": "Error", "message": str(e)}

@app.get("/")
def home():
    return {"message" : "Hello Bank is running"}

@app.get("/balance/{account_id}")
def get_balance(account_id: str):
    balance = accounts.get(account_id, None)
    if balance is None:
        return {"error": "Account not found"}
    return {"account": account_id, "balance": balance}

@app.post("/transfer")
def transfer(from_acc: str, to_acc: str, amount: float):
    if accounts.get(from_acc, 0) < amount:
        return {"errou": "Insufficient funds"}
    accounts[from_acc] -= amount
    accounts[to_acc] = accounts.get(to_acc, 0) + amount
    return {"status": "Transfer done", "form": from_acc, "to": to_acc, "amount": amount}
    