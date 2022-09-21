from flask import (
    Flask,
    render_template,
    request,
    session,
    redirect,
    url_for,
    flash,
    send_file,
)
from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, logout_user, login_manager, LoginManager
from flask_login import login_required, current_user
import json
import os
from flask_ngrok import run_with_ngrok
import pymysql

pymysql.install_as_MySQLdb()

# MY db connection
local_server = True
app = Flask(__name__)
# run_with_ngrok(app)
app.secret_key = "SujithKumarA"
app.debug = True

# this is for getting unique user access
login_manager = LoginManager(app)
login_manager.login_view = "login"


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


# app.config['SQLALCHEMY_DATABASE_URL']='mysql://username:password@localhost/databas_table_name'
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql://root:root@localhost/studentdbms"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
db = SQLAlchemy(app)

# here we will create db models that is tables
class Test(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    email = db.Column(db.String(100))


class Department(db.Model):
    cid = db.Column(db.Integer, primary_key=True)
    branch = db.Column(db.String(100))


class Attendence(db.Model):
    aid = db.Column(db.Integer, primary_key=True)
    rollno = db.Column(db.String(100))
    attendance = db.Column(db.Integer())


class Trig(db.Model):
    tid = db.Column(db.Integer, primary_key=True)
    rollno = db.Column(db.String(100))
    action = db.Column(db.String(100))
    timestamp = db.Column(db.String(100))


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    email = db.Column(db.String(50), unique=True)
    password = db.Column(db.String(1000))


class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    rollno = db.Column(db.String(50))
    sname = db.Column(db.String(50))
    sem = db.Column(db.Integer)
    gender = db.Column(db.String(50))
    branch = db.Column(db.String(50))
    email = db.Column(db.String(50))
    number = db.Column(db.String(12))
    address = db.Column(db.String(100))


class Marks(db.Model):
    SID = db.Column(db.Integer(), primary_key=True)
    KTUID = db.Column(db.String(64))
    C1 = db.Column(db.String(64))
    C2 = db.Column(db.String(64))
    C3 = db.Column(db.String(64))


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/studentdetails")
def studentdetails():
    query = db.engine.execute(f"SELECT * FROM `student`")
    return render_template("studentdetails.html", query=query)


@app.route("/markdetails")
def markdetails():
    query = db.engine.execute(f"SELECT * FROM `marks`")
    return render_template("markdetails.html", query=query)


@app.route("/triggers")
def triggers():
    query = db.engine.execute(f"SELECT * FROM `trig`")
    return render_template("triggers.html", query=query)


@app.route("/search", methods=["POST", "GET"])
def search():
    if request.method == "POST":
        rollno = request.form.get("roll")
        bio = Student.query.filter_by(rollno=rollno).first()
        attend = Attendence.query.filter_by(rollno=rollno).first()
        ktuid = request.form.get("ktuid")
        ktuidquery = Marks.query.filter_by(KTUID=ktuid).first()
        print(db.engine.execute("SELECT * FROM marks"))
        return render_template(
            "search.html", bio=bio, attend=attend, ktuidquery=ktuidquery
        )  # ,ktuidqueryall=ktuidqueryall)

    return render_template("search.html")

@app.route("/query", methods=["POST", "GET"])
def query():
    if request.method == "POST":
        sid=request.form.get("sid")
        ktuid=request.form.get("ktuid")
        subject=request.form.get("subject")
        grade=request.form.get("grade")
        dept=request.form.get("dept")
        # query = db.engine.execute(f"SELECT * FROM `marks` WHERE KTUID = '{ktuid}'")
        sid_d = db.engine.execute(f"SELECT DISTINCT SID FROM `marks`")
        ktuid_d = db.engine.execute(f"SELECT DISTINCT KTUID FROM `marks`")
        subject_d = db.engine.execute(f"SELECT DISTINCT C1 FROM `marks`")
        grade_d = db.engine.execute(f"SELECT DISTINCT C2 FROM `marks`")
        dept_d = db.engine.execute(f"SELECT DISTINCT C3 FROM `marks`")
        # for row in query:
        #     print(row._asdict())
        sid_di=ktuid=request.form.get("sid_di")
        ktuid_di=request.form.get("ktuid_di")
        subject_di=request.form.get("subject_di")
        grade_di=request.form.get("grade_di")
        dept_di=request.form.get("dept_di")
        # dept_subject_d = db.engine.execute(f"SELECT DISTINCT C1 FROM `marks` WHERE C3 = '{dept_di}'")
        query = db.engine.execute(f"SELECT * FROM `marks` WHERE KTUID = '{ktuid_di}'")
        return render_template("query.html", query=query, sid_d=sid_d, ktuid_d=ktuid_d, subject_d=subject_d, grade_d=grade_d, dept_d=dept_d)
    return render_template("query.html")

@app.route("/delete/<string:id>", methods=["POST", "GET"])
@login_required
def delete(id):
    db.engine.execute(f"DELETE FROM `student` WHERE `student`.`id`={id}")
    flash("Slot Deleted Successful", "danger")
    return redirect("/studentdetails")

@app.route("/edit/<string:id>", methods=["POST", "GET"])
@login_required
def edit(id):
    dept = db.engine.execute("SELECT * FROM `department`")
    posts = Student.query.filter_by(id=id).first()
    if request.method == "POST":
        rollno = request.form.get("rollno")
        sname = request.form.get("sname")
        sem = request.form.get("sem")
        gender = request.form.get("gender")
        branch = request.form.get("branch")
        email = request.form.get("email")
        num = request.form.get("num")
        address = request.form.get("address")
        query = db.engine.execute(
            f"UPDATE `student` SET `rollno`='{rollno}',`sname`='{sname}',`sem`='{sem}',`gender`='{gender}',`branch`='{branch}',`email`='{email}',`number`='{num}',`address`='{address}'"
        )
        flash("Slot is Updates", "success")
        return redirect("/studentdetails")

    return render_template("edit.html", posts=posts, dept=dept)


@app.route("/signup", methods=["POST", "GET"])
def signup():
    if request.method == "POST":
        username = request.form.get("username")
        email = request.form.get("email")
        password = request.form.get("password")
        user = User.query.filter_by(email=email).first()
        if user:
            flash("Email Already Exist", "warning")
            return render_template("/signup.html")
        encpassword = generate_password_hash(password)

        new_user = db.engine.execute(
            f"INSERT INTO `user` (`username`,`email`,`password`) VALUES ('{username}','{email}','{encpassword}')"
        )

        # this is method 2 to save data in db
        # newuser=User(username=username,email=email,password=encpassword)
        # db.session.add(newuser)
        # db.session.commit()
        flash("Signup Succes Please Login", "success")
        return render_template("login.html")

    return render_template("signup.html")


@app.route("/login", methods=["POST", "GET"])
def login():
    if request.method == "POST":
        email = request.form.get("email")
        password = request.form.get("password")
        user = User.query.filter_by(email=email).first()

        if user and check_password_hash(user.password, password):
            login_user(user)
            flash("Login Success", "primary")
            return redirect(url_for("index"))
        else:
            flash("invalid credentials", "danger")
            return render_template("login.html")

    return render_template("login.html")


@app.route("/logout")
@login_required
def logout():
    logout_user()
    flash("Logout SuccessFul", "warning")
    return redirect(url_for("login"))


@app.route("/addstudent", methods=["POST", "GET"])
@login_required
def addstudent():
    dept = db.engine.execute("SELECT * FROM `department`")
    if request.method == "POST":
        rollno = request.form.get("rollno")
        sname = request.form.get("sname")
        sem = request.form.get("sem")
        gender = request.form.get("gender")
        branch = request.form.get("branch")
        email = request.form.get("email")
        num = request.form.get("num")
        address = request.form.get("address")
        query = db.engine.execute(
            f"INSERT INTO `student` (`rollno`,`sname`,`sem`,`gender`,`branch`,`email`,`number`,`address`) VALUES ('{rollno}','{sname}','{sem}','{gender}','{branch}','{email}','{num}','{address}')"
        )

        flash("Booking Confirmed", "info")

    return render_template("student.html", dept=dept)


@app.route("/test")
def test():
    try:
        Test.query.all()
        return "My database is Connected"
    except:
        return "My db is not Connected"


app.config["UPLOAD_FOLDER"] = os.getcwd()

# The path for uploading the file
@app.route("/uploads")
def upload_file():
    return render_template("upload.html")


@app.route("/upload", methods=["GET", "POST"])
def uploadfile():
    if request.method == "POST":  # check if the method is post
        f = request.files["file"]  # get the file from the files object
        # Saving the file in the required destination
        f.save(
            os.path.join(app.config["UPLOAD_FOLDER"], "in.pdf")
        )  # this will secure the file
        os.system("bash {0} in.pdf".format(os.path.join(os.getcwd(), "parser.sh")))
        os.system(
            "cp -vf {0} /var/lib/mysql-files/".format(
                os.path.join(os.getcwd(), "in.csv")
            )
        )
        os.system("mysql -u root < {0}".format(os.path.join(os.getcwd(), "import.sql")))
        return render_template("download.html")


# Sending the file to the user
@app.route("/download")
def download():
    return send_file("in.csv", as_attachment=True)


app.run()
