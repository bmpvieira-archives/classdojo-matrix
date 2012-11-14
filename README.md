Finding the Minimum Weight Path Through a Matrix
================================================

Consider a matrix of integers (ie `[[3, 1, 4], [1, 5, 9], [2, 6, 5]]`).
For a better visual, we can draw this matrix like so:

`| 3 1 4 |`  
`| 1 5 9 |`  
`| 2 6 5 |`  

A "path through the matrix" starts at the top of the matrix, ends at the
bottom, never backtracks (goes up), and at each step either moves
below and left, below, or below and right. The "weight" of
a path through the matrix is the sum of the numbers along the path.
In the example, the valid paths through the matrix are:

`[3, 1, 2]       // weight([3, 1, 2]) = 6`  
`[3, 1, 6]       // weight([3, 1, 6]) = 10`  
`[3, 5, 2]       // weight([3, 5, 2]) = 10`  
`[3, 5, 6]       // weight([3, 5, 6]) = 14`  
`[3, 5, 5]       // weight([3, 5, 5]) = 13`  
`...`  
`[4, 9, 5]       // weight([4, 9, 5]) = 18`  

The path with the minimum weight is [1, 1, 2].

For this problem, you'll implement a simple API server to find the weight
of the minimum weight path through the matrix for arbitrary input matrices.
When the server receives a POST request to the root url / with a JSON encoded,
2D array of integers (ie `"[[3,1,4],[1,5,9],[2,6,5]]"`),
it must respond with the weight of the minimum weight path through the matrix.

