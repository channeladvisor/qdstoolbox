<img src="https://raw.githubusercontent.com/channeladvisor/qdstoolbox/main/qdstoolbox.svg" width="200">

# QDS Toolbox
This is a collection of tools (comprised of a combination of views, procedures, functions...) developed using the Query Store functionality as a base to facilitate its usage and reports' generation. These include but are not limited to:

- Implementations of SSMS' GUI reports that can be invoked using T-SQL code, with added funcionalities (parameterization, saving results to tables) so they can be programmatically executed and used to send out mails.

- Quick analysis of a server's overall activity to identify bottlenecks and points of high pressure on the SQL instance at any given time, both in real time or in the past.

- Cleanup of QDS' cache with a smaller footprint than the internal one generates, with customization parameters to enable a customizable cleanup (such as removing information regarding dropped objects, cleaning details of ad-hoc or internal queries executed on the server as index maintenance operations).

All these tools have been tested on SQL 2016, 2017 and 2019 instances, both with Case Sensitive and Insensitive collations and running on both Windows and Linux.
\
Since Query Store did not capture all the information in 2016 as it does in later versions, some funcionalities may suffer restrictions


(Original icon art by https://www.smashicons.com )