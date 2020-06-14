from db import db
from user import models
from book import models
from sqlalchemy.sql import text


if __name__ == "__main__":
    db.Base.metadata.create_all(db.engine)

    # Install pgroonga
    # q1 = text('CREATE EXTENSION pgroonga')
    # q2 = text('CREATE INDEX pgroonga_basebook_index ON basebook USING pgroonga (id, title, author_id, bio, publisher_id)')
    session = db.Session()
    # session.execute(q1)
    # session.execute(q2)
    session.commit()
    session.close()
