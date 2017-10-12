#include <vector>
#include <cstdio>
#include <algorithm>
#include <cstdlib>
#include <set>
#include <queue>
#include <iostream>

using namespace std;

vector<pair <long long, long long> > xP;
vector<pair <long long, long long> > yP;
vector<pair <long long, long long> > islands;
vector<vector <long long> > nearestPoints;
long long COST[200003];
long long x, y, n, cost;
bool visited [200003];

int main() {
  scanf("%lld\n", &n);

  for (int i = 1; i <= n; i++) {
    COST[i] = -1;
    scanf("%lld %lld\n", &x, &y);
    xP.push_back(make_pair(x, i));
    yP.push_back(make_pair(y, i));
    islands.push_back(make_pair(x, y));
  }

  sort(xP.begin(), xP.end());
  sort(yP.begin(), yP.end());
  nearestPoints.resize(n + 2);
  nearestPoints[xP[0].second].push_back(xP[1].second);
  nearestPoints[yP[0].second].push_back(yP[1].second);

  for(int i = 1; i < n - 1; i++) {
    nearestPoints[xP[i].second].push_back(xP[i + 1].second);
    nearestPoints[yP[i].second].push_back(yP[i + 1].second);
    nearestPoints[xP[i].second].push_back(xP[i - 1].second);
    nearestPoints[yP[i].second].push_back(yP[i - 1].second);
  }

  nearestPoints[xP[n - 1].second].push_back(xP[n - 2].second);
  nearestPoints[yP[n - 1].second].push_back(yP[n - 2].second);

  priority_queue <pair <long long, long long> > Q;
  set <pair <long long, long long> > cost_island;
  Q.push(make_pair(0, 0));
  cost_island.insert(make_pair(0, 0));
  pair<long long , long long> el;
  COST[0] = 0;

  while (!cost_island.empty()) {
    auto p = cost_island.begin();
    el = *p;
    cost_island.erase(p);
    if (el.second == n - 1) {
      cout << el.first << endl;
      cost_island.clear();
      continue;
    }
    for (auto iter : nearestPoints[el.second + 1]) {
      x = islands[el.second].first - islands[iter - 1].first;
      if (x < 0) x = -(x);
      y = islands[el.second].second - islands[iter - 1].second;
      if (y < 0) y = -(y);
      cost = el.first + min(x , y);
      if (COST[iter - 1] == -1) {
        COST[iter - 1] = cost;
        cost_island.insert(make_pair(COST[iter - 1], iter - 1));
      } else if (cost < COST[iter - 1]) {
        cost_island.erase(cost_island.find(make_pair(COST[iter - 1], iter - 1)));
        COST[iter - 1] = cost;
        cost_island.insert(make_pair(COST[iter - 1], iter - 1));
      }
      COST[el.second] = 0;
    }
  }
}
