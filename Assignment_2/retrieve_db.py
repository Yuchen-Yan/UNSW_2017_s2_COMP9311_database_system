# IMPORTANT:
#   POSTGRESQL must be running at the local machine and the database ASX has
#   been created and populated.
#   Your POSTGRESQL user must have permission to connect
#   Find pg_hba.conf from this command
#       SHOW hba_file;
#   in POSTGRESQL
#
#
import psycopg2
from psycopg2.extensions import AsIs
import datetime
import subprocess
import os
import sys
from getpass import getpass

s = input("Input your login to PostgreSQL of the local machine\n Leave blank as default: postgres @ localhost : 5432\n")
if len(s) == 0:
    uname = "postgres"
    hst = "localhost"
    prt = "5432"
else:
    s = s.split("@")
    uname = s[0].strip()
    hst = "localhost"
    prt = "5432"
    if len(s) == 2 and s[1] != "":
        s1 = s[1].split(":")        
        hst = s1[0].strip()
        if len(s1) == 2 and s1[1] != "":
            prt = s1[1].strip()
dbn = input("Input the name of your database (default: asx)\n")
if len(dbn) == 0:
    dbn = "asx"
print(f"{uname} on {hst}:{prt}, db {dbn}")
psd = getpass()
lines = []
print("Processing...")
conn = psycopg2.connect(dbname=dbn, user=uname, password=psd, host=hst, port=prt)
conn.autocommit = True
cur = conn.cursor()

def read_cur():
    columns = [desc[0] for desc in cur.description]
    lines.append("\t".join(columns))
    lines.append("--------------------------")
    count = 0
    for tup in cur.fetchall():
        if tup is not None and len(tup) > 0:
            ls = list()
            for elem in tup:
                ls.append(str(elem))
            count += 1
            lines.append("\t\t".join(ls))
    lines.append("--------------------------")
    lines.append(f"({count} rows)")

for i in range(1, 16):
    s = f"SELECT * FROM Q{i};"
    lines.append("\n" + s)
    cur.execute(s)
    read_cur() 

# 16
lines.append(("\n---------------\n>>>Q16 trigger\t\n",))
lines.append("\n>>> Running tests...\n")
lines.append(">>> Here should receive 2 exceptions:\n")
try:
    cur.execute("INSERT INTO Executive VALUES(%s,%s);", ('AAD', 'Mr. Stephen John Mikkelsen BBS, CA'))
except psycopg2.Error as e:
    lines.append("EXCEPTION: " + e.diag.message_primary + '\n')
try:    
    cur.execute("Update Executive set person = 'Mr. Michael Kelly' where code = 'AAD' and person = 'Mr. Charlie Keegan';")
except psycopg2.Error as e:
    lines.append("EXCEPTION: " + e.diag.message_primary + '\n')

lines.append(">>> The below query should be empty:\n")
cur.execute("SELECT * FROM Executive WHERE Code = 'AAD' AND (Person = 'Mr. Stephen John Mikkelsen BBS, CA' or Person = 'Mr. Michael Kelly');")
read_cur()
# restore
lines.append("\n>>> Reverting changes...")
cur.execute("DELETE FROM Executive WHERE Code = 'AAD' AND Person = 'Mr. Stephen John Mikkelsen BBS, CA';")
cur.execute("Update Executive set person = 'Mr. Charlie Keegan' where code = 'AAD' and person = 'Mr. Michael Kelly';")


# 17
lines.append(("\n---------------\n>>>Q17 trigger.\t\n",))
lines.append("\n>>> Running tests...")
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 3, 31), 'WTF', 522000, 10.00))
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 3, 31), 'WSA', 427000, 0.01))
cur.execute("INSERT INTO ASX VALUES('2012-03-31','WHC','2862700','5.59');")
cur.execute("INSERT INTO ASX VALUES('2012-03-31','WBC','19079700','19.88');")
lines.append("\n>>> Now \"star\" should show 3-3-5-1 by rows:\n")
cur.execute("SELECT Code, Star FROM Rating WHERE Code = 'WTF' or Code = 'WSA' or Code = 'WHC' or Code = 'WBC' order by code;")
read_cur()
lines.append("\n>>> Running tests...")
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 4, 1), 'WTF', 522000, 10.00))
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 4, 1), 'WSA', 427000, 0.01))
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 4, 1), 'WHC', 2862700, 50.00))
cur.execute("INSERT INTO ASX VALUES(%s, %s, %s, %s);", (datetime.date(2012, 4, 1), 'WBC', 19079700, 0.01))
lines.append("\n>>> Now \"star\" should show 1-5-3-3 by rows:\n")
cur.execute("SELECT Code, Star FROM Rating WHERE Code = 'WTF' or Code = 'WSA' or Code = 'WHC' or Code = 'WBC' order by code;")
read_cur()
# restore 17
lines.append("\n>>> Reverting changes...")
cur.execute("DELETE FROM ASX WHERE %s > %s;", (AsIs('"Date"'), datetime.date(2012, 3, 30)))
cur.execute("UPDATE Rating SET Star = 3;")


# 18
lines.append("\n---------------\nQ18 trigger.\t\n")
cur.execute('UPDATE ASX SET Price = 1.20, volume = 271200 WHERE %s = %s AND Code = %s;',
            (AsIs('"Date"'), datetime.date(2012, 1, 3), 'AAD'))
cur.execute('UPDATE ASX SET Price = 0.91, volume = 171200 WHERE %s = %s AND Code = %s;',
            (AsIs('"Date"'), datetime.date(2012, 1, 3), 'AAD'))
lines.append(">>> 2 records should appear in ASXLog now:\n\n")
cur.execute("SELECT * FROM ASXLog;")
read_cur()
# resore 18
lines.append("\n>>> Reverting changes...")
cur.execute("DELETE FROM ASXLog;")


filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "view_tests.txt")

with open(filepath, 'w') as f:
    for line in lines:
        if line is None:
            continue
        if isinstance(line, str):
            f.write(line)
        else:
            for item in line:
                f.write(str(item))
                f.write('\t')
        f.write('\n')

print("\nTest output file saved to:")
print(os.path.abspath(filepath))

if sys.platform.startswith('darwin'):
    subprocess.call(('open', filepath))
elif os.name == 'nt':
    os.startfile(filepath)
elif os.name == 'posix':
    subprocess.call(('vi', filepath))
