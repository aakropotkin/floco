
#include <iostream>
#include <list>
#include <stack>
#include <fstream>
#include <string>
#include <unordered_set>
#include <utility>
#include <set>
#include <unordered_map>
#include <vector>

class Graph
{
  int V;                 /* No. of vertices */
  std::list<int> * adj;  /* An array of adjacency lists */

  /**
    * Fills Stack with vertices (in increasing order of finishing
    * times).
    * The top element of stack has the maximum finishing time.
    */
  void fillOrder( int v, bool visited[], std::stack<int> & Stack );

  /* A recursive function to print DFS starting from v. */
  void DFSUtil( int v, bool visited[] );

public:
  Graph( int V );
  void addEdge( int v, int w );

  /* The main function that finds and prints strongly connected components. */
  void printSCCs();

  /* Function that returns reverse ( or transpose ) of this graph. */
  Graph getTranspose();
};

Graph::Graph(int V)
{
  this->V = V;
  adj = new std::list<int>[V];
}

/* A recursive function to print DFS starting from v. */
  void
Graph::DFSUtil( int v, bool visited[] )
{
  /* Mark the current node as visited and print it. */
  visited[v] = true;
  std::cout << v << " ";

  /* Recur for all the vertices adjacent to this vertex. */
  std::list<int>::iterator i;
  for ( i = adj[v].begin(); i != adj[v].end(); ++i )
    {
      if ( ! visited[*i] )
        {
          DFSUtil( *i, visited );
        }
    }
}


  Graph
Graph::getTranspose()
{
  Graph g( V );
  for ( int v = 0; v < V; v++ )
    {
      /* Recur for all the vertices adjacent to this vertex. */
      std::list<int>::iterator i;
      for( i = adj[v].begin(); i != adj[v].end(); ++i )
        {
          g.adj[*i].push_back( v );
        }
    }
  return g;
}


  void
Graph::addEdge( int v, int w )
{
  adj[v].push_back( w );  /* Add w to v’s list. */
}


  void
Graph::fillOrder( int v, bool visited[], std::stack<int> & Stack )
{
  /* Mark the current node as visited and print it. */
  visited[v] = true;

  /* Recur for all the vertices adjacent to this vertex. */
  std::list<int>::iterator i;
  for( i = adj[v].begin(); i != adj[v].end(); ++i )
    {
      if ( ! visited[*i] )
        {
          fillOrder( *i, visited, Stack );
        }
    }

  /* All vertices reachable from v are processed by now, push v. */
  Stack.push( v );
}


/* The main function that finds and prints all strongly connected components. */
  void
Graph::printSCCs()
{
  std::stack<int> Stack;

  /* Mark all the vertices as not visited ( for first DFS ). */
  bool * visited = new bool[V];
  for( int i = 0; i < V; i++ )
    {
      visited[i] = false;
    }

  // Fill vertices in stack according to their finishing times
  for( int i = 0; i < V; i++ )
    {
      if ( visited[i] == false )
        {
          fillOrder( i, visited, Stack );
        }
    }

  /* Create a reversed graph. */
  Graph gr = getTranspose();

  /* Mark all the vertices as not visited ( for second DFS ). */
  for( int i = 0; i < V; i++ )
    {
      visited[i] = false;
    }

  /* Now process all vertices in order defined by Stack. */
  while ( Stack.empty() == false )
    {
      /* Pop a vertex from stack. */
      int v = Stack.top();
      Stack.pop();

      /* Print Strongly connected component of the popped vertex. */
      if ( visited[v] == false )
        {
          gr.DFSUtil( v, visited );
          std::cout << std::endl;
        }
    }
}


/* Driver program to test above functions. */
  int
main( int argc, char * argv[], char ** envp )
{
  std::istream * in;
  if ( 1 < argc )
    {
      in = new std::ifstream( argv[1] );
    }
  else
    {
      in = & std::cin;
    }

  std::string from, to;

  std::unordered_set<std::string>               nodeNames;
  std::set<std::pair<std::string, std::string>> edges;

  while ( *in >> from >> to  )
    {
      nodeNames.insert( from );
      nodeNames.insert( to );
      edges.insert( std::make_pair( from, to ) );
    }

  std::unordered_map<std::string, int> nodeMap;
  std::vector<std::string>             nodeNamesVec( nodeNames.size() );

  auto it = nodeNames.begin();
  for ( int i = 0; it != nodeNames.end(); ++i, ++it )
    {
      nodeNamesVec[i] = *it;
      nodeMap[*it]    = i;
      std::cout << i << " " << *it << std::endl;
    }
  std::cout << std::endl;

  /* Create a graph given in the above diagram. */
  Graph g( nodeNames.size() );
  for ( auto edge : edges )
    {
      g.addEdge( nodeMap[edge.first], nodeMap[edge.second] );
    }
  g.printSCCs();

  return 0;
}
