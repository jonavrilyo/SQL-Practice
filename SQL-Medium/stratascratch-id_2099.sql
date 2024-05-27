/* Election Results
The election is conducted in a city and everyone can vote for one or more candidates, or choose not to vote at all. 
Each person has 1 vote so if they vote for multiple candidates, their vote gets equally split across these candidates. 
For example, if a person votes for 2 candidates, these candidates receive an equivalent of 0.5 vote each.
Find out who got the most votes and won the election. Output the name of the candidate or multiple names in case of a tie. 
To avoid issues with a floating-point error you can round the number of votes received by a candidate to 3 decimal places.
https://platform.stratascratch.com/coding/2099-election-results?code_type=1
*/

-- Using CTEs (this looks much more organized to my eyes):

WITH weighted_vote AS
    (
    SELECT
        voter,
        candidate,
        1 / COUNT(voter) OVER(PARTITION BY voter)::decimal AS weighted_vote
    FROM voting_results
    WHERE candidate IS NOT NULL
    )
,
rank AS 
    (
    SELECT
        candidate,
        DENSE_RANK() OVER(ORDER BY ROUND(SUM(weighted_vote), 3) DESC) AS rank
    FROM weighted_vote
    GROUP BY 1
    )
SELECT
    candidate
FROM rank
WHERE rank = 1;

-- or using a subqueries

SELECT
    candidate
FROM
    (
	SELECT
		candidate,
		DENSE_RANK() OVER(ORDER BY ROUND(SUM(weighted_vote), 3) DESC) AS rank
	FROM
		(
		SELECT
			voter,
			candidate,
			1 / COUNT(voter) OVER(PARTITION BY voter)::decimal AS weighted_vote
		FROM voting_results
		WHERE candidate IS NOT NULL
		) AS vote_values
	GROUP BY 1
    ) rankings
WHERE rank = 1;

-- Understanding the query

-- The FROM subquery within the main subquery is what we should look at first. Here we are extracting a subset of the table that selects the voter, candidate, and an arithmetic function over a window function.
-- For example, Andrew voted for two candidates. His singular vote will be divided by 2. Therefore, each candidate will recieve half a vote (0.5):

/*
SELECT
    voter,
    candidate,
    1 / COUNT(voter) OVER(PARTITION BY voter)::decimal AS weighted_vote
FROM voting_results
WHERE candidate IS NOT NULL
*/

-- Now, we select candidate, add the votes, and use DENSE_RANK() to rank the candidates by the total votes:

/*
SELECT
	candidate,
	DENSE_RANK() OVER(ORDER BY ROUND(SUM(vote_value), 3) DESC) AS rank
*/
    
-- Finally, set up the outer query to select the candidate who received the most votes:

/*
SELECT candidate
FROM
	(
	subquery
	)
WHERE rank = 1
*/