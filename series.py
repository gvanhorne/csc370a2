import psycopg2
import sys

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ./series.py <title of series>")
        sys.exit(1)
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
      title = sys.argv[1]
      title = f"'{title}'" if not title.startswith("'") and not title.endswith("'") else title
      # Connect to the PostgreSQL database
      conn = psycopg2.connect(**db_config)

      # Create a cursor object
      cursor = conn.cursor()

      # Execute SQL queries here
      cursor.execute(f"SELECT * FROM user014_series({title});")

      # Fetch and print results
      rows = cursor.fetchall()

      (series, year, num_seasons, num_episodes, runtime, rating, votes) = rows[0]
      if series == None:
        print('Series not found or duplicate series found')
      else:

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

        cursor.close()
        
        cursor = conn.cursor()

        cursor.execute(f"SELECT * FROM user014_episodes({title});")
        rows = cursor.fetchall()
        # Define the table headings
        headings = ['Season', 'Year', 'Episodes', 'Avg. Votes', 'Avg. Rating', 'Difference']

        # # Create the HTML table
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

        # Print the HTML table
        print(html_table)

    except (Exception, psycopg2.Error) as error:
        print("Error connecting to PostgreSQL:", error)
        sys.exit(1)

    finally:
        if conn:
            # Close the cursor and the database connection
            cursor.close()
            conn.close()
            sys.exit(0)