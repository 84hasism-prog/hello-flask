import os
from flask import Flask, request, redirect
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from dotenv import load_dotenv

# Ladda variabler från .env-filen (används lokalt)
load_dotenv()

app = Flask(__name__)

# --- KONFIGURATION ---
# Använder SQLite lokalt och i molnet som standard tills du kopplar en extern DB
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///newsflash.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'en-valdigt-hemlig-nyckel-123')

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# --- DATABASMODELL ---
class Subscriber(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)

# Skapa tabeller om de inte finns (bra för enkel deploy)
with app.app_context():
    db.create_all()

# --- ROUTES ---
@app.route('/')
def index():
    subscribers = Subscriber.query.all()
    sub_list = "".join([f"<li>{s.email}</li>" for s in subscribers])
    
    return f"""
    <html>
        <body>
            <h1>🚀 News Flash: Google Cloud Edition</h1>
            <form action="/subscribe" method="post">
                <input type="email" name="email" placeholder="Din e-post" required>
                <button type="submit">Prenumerera</button>
            </form>
            <h2>Prenumeranter i databasen:</h2>
            <ul>{sub_list}</ul>
        </body>
    </html>
    """

@app.route('/subscribe', methods=['POST'])
def subscribe():
    email = request.form.get('email')
    if email:
        new_sub = Subscriber(email=email)
        try:
            db.session.add(new_sub)
            db.session.commit()
        except:
            db.session.rollback()
    return redirect('/')

# --- STARTA APPEN ---
if __name__ == "__main__":
    # GCP sätter PORT-variabeln till 8080
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)