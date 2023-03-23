-- The data consists of the following columns:
/* Player Name(Player), Player Team(Team), Match Type(Type), Matches(M), Innings(Inn), Not Out(NO), Runs, Highest Score(HS), 
Batting Average(Avg), Bowls Faced(BF), Strike Rate(SR), 4s, 6s, 50, 100, 200 */

-- I am querying data from two tables to check different stats from Cricket data. This data is from 2020. It includes data of players from different formats including T20, ODI, Tests and IPL (League). Stats table has batting data and bowling table has bowling data.

/* Beginner concepts used in the project include Select, from, where, group by, order by, aggregate functions, Limit and offset, Create table and insert date.
Intermediate concepts used in the project include Joins, Union, Case statement, Having statement and Partition by.
Advanced concepts used in the project include CTEs (Common Table Expression), Temp Tables and Stored procedures. */

-- Data preview
SELECT *
FROM stats;

SELECT *
FROM bowl;

-- Checking data types and other information about the tables
DESCRIBE stats;

DESCRIBE bowl;

-- Checking total values in both tables

SELECT COUNT(*)
FROM stats;

SELECT COUNT(*)
FROM bowl;



-- EXPLORARY DATA ANALYSIS



-- Top 5 Players (based on most runs scored) in T20 format
SELECT player, team, type, runs
FROM stats
WHERE type = "T20"
ORDER BY runs DESC
LIMIT 5;

-- Top 3 players (based on most matches played) in ODI format
SELECT Player, Team, Type, M AS MatchesPlayed
FROM stats
WHERE type = "ODI"
ORDER BY M DESC
LIMIT 3;


-- Players with at least 1 double hunderd in any format
SELECT *
FROM stats
WHERE stats.200 >= 1;

-- Players having batting average of more than 50 and strike rate of more than 100 (30 matches minimum)
SELECT Player AS GOATs, Team, Type AS FormatType, Avg AS BattingAverage, SR AS StrikeRate
FROM stats
WHERE Avg > 50 AND SR > 100 AND M > 30
ORDER BY Avg DESC, SR DESC;


-- Most team runs (based on sum of total runs scored by players) in International Cricket
SELECT Team, SUM(Runs) MostTeamRuns
FROM stats
WHERE type IN ("T20", "ODI", "Test")
GROUP BY Team
ORDER BY MostTeamRuns DESC;

-- Player with most sixes in T20 format
SELECT Player, Team, Type, MAX(6s)
FROM stats
WHERE type = "T20";

-- Average runs of Pakistan team (sum of total runs scored by players) in different Cricket formats
SELECT Team, Type, AVG(Runs) AS AverageRuns
FROM stats
WHERE Team = "Pakistan"
GROUP BY  Type
ORDER BY AverageRuns DESC;

-- Team (sum of runs of all players of the team) which has scored the most runs in Tests (excluding Ireland and Afghanistan)
SELECT Team, SUM(Runs)
FROM stats
WHERE type = "Test"
GROUP BY Team
HAVING NOT Team = "Ireland" AND NOT team = "Afghanistan"
ORDER BY 2 DESC;


-- Runs and wickets of Pakistani squad in T20s
SELECT s.Player, s.Team, s.Runs, b.Wkts AS Wickets
FROM stats s
JOIN bowl b
	ON s.Player = b.Player
WHERE s.type = "T20" AND b.type = "T20" AND s.Team = "Pakistan";

-- Classification of players based on runs in ODIs
SELECT Player, Team, Runs,
	CASE
		WHEN Runs > 10000 THEN "Legendry"
		WHEN Runs > 8000 THEN "Pro"
		WHEN Runs > 5000 THEN "Good"
		WHEN Runs = 0 THEN "Did not play"
		ELSE "Newbie or Noob"
	END AS Player_Classification
FROM stats
WHERE type = "ODI"
ORDER BY 3 DESC;

-- Checking total distinct players in both batting (stats) and bowlling (bowl) tables
SELECT Player, Team, M AS Matches
FROM stats
UNION
SELECT Player, Team, M AS Matches
FROM bowl;

-- Checking the total runs of each player in Indian Cricket team in T20 while also showing average runs of all the players in T20 and clasifying them
SELECT Player, Type, Runs, AVG(Runs) OVER (PARTITION BY Team) AS AverageRuns,
	CASE
		WHEN Runs > AVG(Runs) OVER (PARTITION BY Team) + 100 THEN "Good"
		WHEN Runs < AVG(Runs) OVER (PARTITION BY Team) - 100 THEN "Bad"
        Else "Okay"
	END AS ClassificationOnRuns
FROM stats
WHERE Type = "T20" AND Team = "India";

-- Players who have minimum 100 wickets and at least 2000 runs in Tests
WITH CTE_Bowler AS
(SELECT Player, Team, Type, M, Wkts
FROM bowl
WHERE Wkts >= 100 AND Type = "Test"
)
SELECT CTE.Player, CTE.Team, CTE.Type, CTE.M, CTE.Wkts, S.Runs
FROM CTE_Bowler CTE
JOIN stats S
	ON CTE.Player = S.Player
WHERE S.Runs > 1999 AND S.Type = "Test"; 
-- We get the top 5 all-rounders of Test cricket.

-- Players who have scored more than 100 sixes and played at least 50 matches in T20 format. Also they have a bowling economy greater than 1 (to ensure they have bowled in T20)
DROP TEMPORARY TABLE IF EXISTS temp_Bowlers;

CREATE TEMPORARY TABLE temp_Bowlers (
Player varchar(50),
Team Varchar(25),
Matches Int,
Economy Decimal);

INSERT INTO temp_Bowlers
SELECT Player, Team, M, Econ
FROM bowl
WHERE M > 50 AND Econ > 1;

SELECT T.Player, T.Team, S.Type, T.Matches, 6s as Sixes, T.Economy
FROM stats S
INNER JOIN temp_Bowlers T
	ON S.Player = T.Player
WHERE 6s > 100 AND Type = "T20"
GROUP BY T.Player
ORDER BY 5 DESC, 6 DESC;

-- Doing the same but giving the format (type) as a user input.
DROP PROCEDURE IF EXISTS proc_bowlers;
DELIMITER //
CREATE PROCEDURE proc_bowlers(IN p_type VARCHAR(10))
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_Bowlers2;
    CREATE TEMPORARY TABLE temp_Bowlers2 (
        Player varchar(50),
        Team Varchar(25),
        Matches Int,
        Economy Decimal
    );
    
    INSERT INTO temp_Bowlers2
    SELECT Player, Team, M, Econ
    FROM bowl
    WHERE M > 50 AND Econ > 1;

    SELECT Te.Player, Te.Team, St.Type, Te.Matches, 6s as Sixes, Te.Economy
    FROM stats St
    INNER JOIN temp_Bowlers2 Te
        ON St.Player = Te.Player
    WHERE 6s > 100 AND Type = p_type
    GROUP BY Te.Player
    ORDER BY 5 DESC, 6 DESC;
END //
DELIMITER ;

CALL proc_bowlers("T20");

-- There is a lot more which could be explored from the data but I have got good insights out of it.
