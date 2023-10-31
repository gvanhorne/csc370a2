import psycopg2
import sys

def print_series_info(data):
    (series, year, num_seasons, num_episodes, runtime, rating, votes) = data[0]
    html_output = f"<ul>"
    html_output += f"<li>Series: {series}</li>"
    html_output += f"<li>Year: {year}</li>"
    html_output += f"<li>Number of Seasons: {num_seasons}</li>"
    html_output += f"<li>Number of Episodes: {num_episodes}</li>"
    html_output += f"<li>Runtime: {runtime}</li>"
    html_output += f"<li>Rating: {rating}</li>"
    html_output += f"<li>Votes: {votes}</li>"
    html_output += f"</ul>"

    print(html_output)

def print_season_info(data):
    headings = ['Season', 'Year', 'Episodes', 'Avg. Votes', 'Avg. Rating', 'Difference']

    html_table = '<table border="1">\n'
    html_table += '<tr>'
    for heading in headings:
        html_table += f'<th>{heading}</th>'
    html_table += '</tr>\n'

    for row in rows:
        html_table += '<tr>'
        for value in row:
            html_table += f'<td>{value}</td>'
        html_table += '</tr>\n'

    html_table += '</table>'
    print(html_table)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ./series.py <title of series>")
        sys.exit(1)
    title = sys.argv[1]

    print("Enter the database username:", file=sys.stderr)
    db_user = input()
    print("Enter the database password:", file=sys.stderr)
    db_password = input()
    db_config = {
      "host": 'pgstudent.csc.uvic.ca',
      "database": 'imdb',
      "user": db_user,
      "password": db_password,
    }

    try:
      conn = psycopg2.connect(**db_config)
      cursor = conn.cursor()

      cursor.execute("SELECT * FROM user014_series(%s);", (title,))

      rows = cursor.fetchall()

      if rows[0][0] == None:
        print('Series not found or duplicate series found')
      else:
        ## Print series info in a list
        print_series_info(rows)
        cursor.close()
        
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM user014_episodes(%s);", (title,))
        rows = cursor.fetchall()

        print_season_info(rows)

    except (Exception, psycopg2.Error) as error:
        print("Error connecting to PostgreSQL:", error)
        sys.exit(1)

    finally:
        if conn:
            cursor.close()
            conn.close()
            sys.exit(0)