# PivotedWaitStats
The design of the <b>sys.query_store_wait_stats</b> differs from <b> sys.query_store_runtime_stats</b> , by having on row for each wait type, per plan, per runtime stats interval. This reduces the space requirements since most plans will have no wait times, or only a few types of them, but makes it difficult to compare it with the runtime stats.\
This view pivots the different rows into Total & Average columns for each wait type.
(Supported in SQL 2017+: for SQL 2016 the view will not be created)