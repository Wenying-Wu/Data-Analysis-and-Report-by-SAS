
**********************************************************************;
/* prexlsx to sas */

%web_drop_table(WORK.EPLResultsData);


FILENAME REFFILE '/home/u49540231/awinnie/EPL Results from 2010 to 2020 - for SAS.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	
	OUT=WORK.EPLResultsData;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.EPLResultsData; RUN;


%web_open_table(WORK.EPLResultsData);

**********************************************************************;
**********************************************************************;
/* the data is from Wikipedia.*/
/* 2010-11: 19th, 14 August 2010-22 May 2011.
/* 2011-12: 20th, 13 August 2011-13 May 2012.
/* 2012–13: 21st, 18 August 2012-19 May 2013.
/* 2013–14: 22nd, 17 August 2013-11 May 2014.
/* 2014–15: 23rd, 16 August 2014-24 May 2015.
/* 2015–16: 24th, 8 August 2015-17 May 2016.
/* 2016–17: 25th, 13 August 2016-21 May 2017.
/* 2017–18: 26th, 11 August 2017-13 May 2018.
/* 2018–19: 27th, 10 August 2018-12 May 2019.
/* 2019-20: 28th, 9 August 2019-26 July 2020.*/

/* change data and label */
data work.EPLResult_notsorted;
	format Date Referee HomeTeam2 AwayTeam2 FTR2 WinTeam Difference FTHG2 FTAG HS AS HST AST HF AF Year;
	length HomeTeam2 $21;
	format AS HS BEST.;
    set work.eplresultsdata;
    format Date Date9.;
	Referee=propcase(Referee);
	
	If "14Aug2010"d <= Date <= "22May2011"d then do;
		Season = "2010-11";
		end;
	else if "13Aug2011"d <= Date <= "13May2012"d then do;
		Season = "2011-12";
		end;
	else if "18Aug2012"d <= Date <= "19May2013"d then do;
		Season = "2012-13";
		end;
	else if "17Aug2013"d <= Date <= "11May2014"d then do;
		Season = "2013-14";
		end;
	else if "16Aug2014"d <= Date <= "24May2015"d then do;
		Season = "2014-15";
		end;
	else if "8Aug2015"d <= Date <= "17May2016"d then do;
		Season = "2015-16";
		end;
	else if "13Aug2016"d <= Date <= "21May2017"d then do;
		Season = "2016-17";
		end;
	else if "11Aug2017"d <= Date <= "13May2018"d then do;
		Season = "2017-18";
		end;
	else if "10Aug2018"d <= Date <= "12May2019"d then do;
		Season = "2018-19";
		end;
	else if "9Aug2019"d <= Date <= "26Jul2020"d then do;
		Season = "2019-20";
		end;

	
	If HomeTeam = "Man City" then do;
		HomeTeam2 = "Manchester City";
		end;
	else if HomeTeam = "Man United" then do;
		HomeTeam2 = "Manchester United";
		end;
	else if HomeTeam = "LIVERPOOL" then do;
		HomeTeam2 = "Liverpool";
		end;
	else do;
		HomeTeam2 = HomeTeam;
		end;
	format AwayTeam2 $18.;
	If AwayTeam = "Man City" then do;
		AwayTeam2 = "Manchester City";
		end;
	else if AwayTeam = "Man United" then do;
		AwayTeam2 = "Manchester United";
		end;
	else do;
		AwayTeam2 = AwayTeam;
		end;
	
	If FTHG = 'Two' then do;
		FTHG2 = 2;
		end;
	else do; 
		FTHG2 = FTHG;
		end;
	
	Difference = FTHG2 - FTAG;
	IF Difference >= 1 then do;
		FTR2 = "Home";
		end;
	else if Difference < 0 then do;
		FTR2 = "Away";
		end;
	else do;
		FTR2 = "Draw";
		end;
	
	If FTR2 = "Home" then do;
		WinTeam = HomeTeam2;
		end;
	else if FTR2 = "Away" then do;
		WinTeam = AwayTeam2;
		end;
	
    Year=Date;
    Month=Date;
    Day=Date; 
    format Year Year.;
    format Month MONTH9.;
    format Day DAY.; 
 	label HomeTeam2 = "Home Team"
 		AwayTeam2 = "Away Team"
		FTHG2 = "Full time Home Team Goals"
		FTAG = "Full time Away Team Goals"
		FTR2 = "Full time result (Home, Away, Draw)"
		Referee = "Referee name"
		HS = "Home Team shots"
		AS = "Away Team shots"
		HST = "Home Team shots on target"
		AST = "Away Team shots on target"
		HF = "Home Team fouls"
		AF = "Away Team fouls";		
	Result = cats(FTHG2,'-',FTAG);
run;   
    

**********************************************************************;
/* sort */

proc sort data=work.EPLResult_notsorted out=work.EPLResult_sort;
	by _all_;
run;


**********************************************************************;
/* remove duplicate */

proc sort data=work.EPLResult_sort out=work.EPLResult
	dupout=EPLResult_dup
	noduprecs;
	by _all_;
run;

**********************************************************************;
**********************************************************************;
**********************************************************************;
**********************************************************************;
/* new table for every team (each game has two record, oe is home team, one is away team)  */
	
data Teamdraft;
	format Date Referee Team HomeTeam2 AwayTeam2 Position Winteam FTHG FTAG FTR2 ;

	set work.eplresult;
	Team=HomeTeam2;
	output;
	Team=AwayTeam2;
	output;	
run;	

**********************************************************************;
/* add variables*/

data Team;
	format FullTimeGoals BEST.;
	format AwayGoalConcede BEST.;

	format Date Referee Team Position Wintype Win GameResult Winteam QualityOfShot FullTimeGoals GoalKept GoalConcede FTHG2 FTAG  FTR2 HomeST AwayST ShotOnTarget Shot HomeShot AwayShot HF AF Fouls;
	set work.Teamdraft;
	if Team = HomeTeam2 then do;
		Position = "Home";
		end;	
	else if Team = AwayTeam2 then do; 
		Position = "Away";
		end;	
		
	if Winteam=Team then do;
		Win="Win";
		GameResult = 1;
		end;
	else do GameResult = 0;
		end;
		
	if (Position="Home" and Win = "Win") then do;
		Wintype="Home Win";
		end;
	else if (Position="Away" and Win = "Win") then do;
		Wintype="Away Win";
		end;
	if Position="Home" then do; 
		FullTimeGoals = FTHG2;
		HomeFullTimeGoals = FTHG2;
		GoalKept = AST - FTAG;
		HomeGoalkept = AST - FTAG;
		GoalConcede = FTAG;
		HomeGoalConcede = FTAG;
		ShotOnTarget = HST;
		HomeST = HST;
		Fouls = HF;
		HomeFouls = HF;
		Shot = HS;
		HomeShot = HS;
		end;
	else if Position="Away" then do;
		FullTimeGoals = FTAG;
		AwayFullTimeGoals = FTAG;
		GoalKept = HST - FTHG2;
		AwayGoalkept = HST - FTHG2;
		GoalConcede = FTHG2;
		AwayGoalConcede = FTHG;
		ShotOnTarget = AST;
		AwayST = AST;
		Fouls = AF;
		AwayFouls = AF;
		Shot = AS;
		AwayShot = AS;
		end;
		
	QualityOfShot = FullTimeGoals/Shot;
 	format QualityOfShot percent8.2;
run;

**********************************************************************;
**********************************************************************;
**********************************************************************;
/*Season summary table */

proc sql;
	create table Seasonsummary as
	select Season as Season,
			count(*)/2 as NOGame,
			sum(Position="Home") as NOHomeTeam,
			sum(Position="Away") as NOAwayTeam,			
			sum(Wintype="Home Win") as NOHomeWin,
			sum(Wintype="Away Win") as NOAwayWin,
			count(Win) as NOWin,
			sum(Wintype="Home Win")/sum(Position="Home") as HomeWinRate format=percent8.2,
			sum(Wintype="Away Win")/sum(Position="Away") as AwayWinRate format=percent8.2,
			count(Win)/(count(*)/2) as WinRate format=percent8.2,/*win rate  */
			1-(count(Win)/(count(*)/2)) as DrawRate format=percent8.2,/*win rate  */

			sum(Shot) as Shots,
			sum(Shot)/count(*) as AverageShots format=decimal8., /*shot  */
			sum(HomeShot)/sum(Position="Home") as HomeAverageShots format=decimal8.,
			sum(AwayShot)/sum(Position="Away") as AwayAverageShots format=decimal8.,
			
			sum(FullTimeGoals)/count(*) as AverageFullTimeGoals,
			sum(ShotOnTarget) as TST,
			sum(HomeST) as HST,			
			sum(AwayST) as AST,
			sum(HomeST)+sum(AwayST) as TOST,
			
			sum(ShotOnTarget)/count(*) as AverageShotsOnTarget format=decimal8.,
			sum(HomeST)/sum(Position="Home") as HomeAverageShotsOnTarget format=decimal8.,
			sum(AwayST)/sum(Position="Away") as AwayAverageShotsOnTarget format=decimal8.,
			/*shot on target */
			
			sum(FullTimeGoals)/sum(ShotOnTarget) as GoalRateOnShotsOnTarget format=percent8.2,
			sum(HomeFullTimeGoals)/sum(HomeST) as HomeGoalRateOnShotsOnTarget format=percent8.2,
			sum(AwayFullTimeGoals)/sum(AwayST) as AwayGoalRateOnShotsOnTarget format=percent8.2,
			

			sum(FullTimeGoals)/sum(Shot) as  GoalRateOnShots format=percent8.2,
			sum(HomeFullTimeGoals)/sum(HomeShot) as HomeGoalRateOnShots format=percent8.2,
			sum(AwayFullTimeGoals)/sum(AwayShot) as AwayGoalRateOnShots format=percent8.2,
			
			sum(GoalKept) as TotalGoalKept,
			sum(HomeGoalKept) as HomeGoalKept,
			sum(AwayGoalKept) as AwayGoalKept,			
			sum(GoalKept)/count(*) as AverageGoalKept format=decimal8.,
			sum(HomeGoalKept)/sum(Position="Home") as HomeAverageGoalKept format=decimal8.,
			sum(AwayGoalKept)/sum(Position="Away")as AwayAverageGoalKept format=decimal8.,

			
			sum(GoalConcede) as TotalGoalConcede,
			sum(HomeGoalConcede) as HomeGoalConcede,
			sum(AwayGoalConcede) as AwayGoalConcede,
			sum(GoalConcede)/count(*) as AverageGoalConcede format=decimal8.,
			sum(HomeGoalConcede)/sum(Position="Home") as HomeAverageGoalConcede format=decimal8.,
			sum(AwayGoalConcede)/sum(Position="Away")as AwayAverageGoalConcede format=decimal8.,

			sum(HomeFouls) as HomeFouls,
			sum(AwayFouls) as AwayFouls,
			sum(Fouls) as TotalFouls,
			sum(Fouls)/count(*) as AverageFouls format=decimal8.,
			sum(HomeFouls)/sum(Position="Home") as HomeAverageFouls format=decimal8.,
			sum(AwayFouls)/sum(Position="Away")as AwayAverageFouls format=decimal8.

	from work.Team
	group by Season;
quit;

data work.Season;
	format AverageShotsOnTarget HomeAverageShotsOnTarget AwayAverageShotsOnTarget AverageShots HomeAverageShots AwayAverageShots AverageFouls HomeAverageFouls AwayAverageFouls AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept AverageFouls HomeAverageFouls AwayAverageFouls 10.2;
	set work.Seasonsummary;
 	label NOGame = "Number of Game"
 		NOHomeTeam = "Number of Home Team"
		NOAwayTeam = "Number of Away Team"
		NOWin = "Number of Win"
		HomeWinRate = "Home Win Rate"
		AwayWinRate = "Away Win Rate"
		WinRate = "Win Rate"
		DrawRate = "Draw Rate"
		AverageShots = "Average Shots"
		HomeAverageShots = "Home Average Shots"
		AwayAverageShots = "Away Average Shots"
		AverageFullTimeGoals ="Average Full Time Goals"
		TOST = "Total Shots on Target"
		HST = "Home Shots on target "
		AST = "Away Shots on target"
		AverageShotsOnTarget = "Average Shots On Target" 
		HomeAverageShotsOnTarget = "Home Average Shots On Target"
		AwayAverageShotsOnTarget = "Away Average Shots On Target"
		
		GoalRateOnShotsOnTarget = "Goal Rate On Shots On Target"
		HomeGoalRateOnShotsOnTarget = "Home Goal Rate On Shots On Target"
		AwayGoalRateOnShotsOnTarget = "Away Goal Rate On Shots On Target"
		
		GoalRateOnShots = "Goal Rate On Shots"
		HomeGoalRateOnShots = "Home Goal Rate On Shots"
		AwayGoalRateOnShots = "Away Goal Rate On Shots"
		
		TotalGoalKept = "Total Goal Kept"
		AverageGoalKept = "Average Goal Kept"
		HomeAverageGoalKept = "Home Average Goal Kept"		
		AwayAverageGoalKept = "Away Average Goal Kept"

		TotalGoalConcede = "Total Goal Concede"
		AverageGoalConcede = "Average Goal Concede"
		HomeAverageGoalConcede = "Home Average Goal Concede"		
		AwayAverageGoalConcede = "Away Average Goal Concede"

		
		TotalFouls = "Total Fouls"
		AverageFouls = "Average Fouls"
		HomeAverageFouls = "Home Average Fouls"		
		AwayAverageFouls = "Away Average Fouls";
run;   


**********************************************************************;
**********************************************************************;
**********************************************************************;
**********************************************************************;
/*team summary table */

proc sql;
	create table teamsummary as
	select Team as Team,
			count(*) as NOGame,
			sum(Position="Home") as NOHomeGame,
			sum(Position="Away") as NOAwayGame,			
			sum(Wintype="Home Win") as NOHomeWin,
			sum(Wintype="Away Win") as NOAwayWin,
			count(Win) as NOWin,
			sum(Wintype="Home Win")/sum(Position="Home") as HomeWinRate format=percent8.2,
			sum(Wintype="Away Win")/sum(Position="Away") as AwayWinRate format=percent8.2,
			count(Win)/count(*) as WinRate format=percent8.2,/*win rate  */

			sum(Shot) as Shot,
			sum(Shot)/count(*) as AverageShots format=decimal8.,/*shot  */
			sum(HomeShot)/sum(Position="Home") as HomeAverageShots format=decimal8.,
			sum(AwayShot)/sum(Position="Away") as AwayAverageShots format=decimal8.,
			
			sum(FullTimeGoals)/count(*) as AverageFullTimeGoals,
			sum(ShotOnTarget) as TST,
			sum(HomeST) as HST,			
			sum(AwayST) as AST,
			sum(HomeST)+sum(AwayST) as TOST,
			
			sum(ShotOnTarget)/count(*) as AverageShotsOnTarget format=decimal8.,
			sum(HomeST)/sum(Position="Home") as HomeAverageShotsOnTarget format=decimal8.,
			sum(AwayST)/sum(Position="Away") as AwayAverageShotsOnTarget format=decimal8.,/*shot on target */
			
			sum(FullTimeGoals)/sum(ShotOnTarget) as GoalRateOnShotsOnTarget format=percent8.2,
			sum(HomeFullTimeGoals)/sum(HomeST) as HomeGoalRateOnShotsOnTarget format=percent8.2,
			sum(AwayFullTimeGoals)/sum(AwayST) as AwayGoalRateOnShotsOnTarget format=percent8.2,
			

			sum(FullTimeGoals)/sum(Shot) as  GoalRateOnShots format=percent8.2,
			sum(HomeFullTimeGoals)/sum(HomeShot) as HomeGoalRateOnShots format=percent8.2,
			sum(AwayFullTimeGoals)/sum(AwayShot) as AwayGoalRateOnShots format=percent8.2,
			
			sum(GoalKept) as TotalGoalKept,
			sum(HomeGoalKept) as HomeGoalKept,
			sum(AwayGoalKept) as AwayGoalKept,			
			sum(GoalKept)/count(*) as AverageGoalKept,
			sum(HomeGoalKept)/sum(Position="Home") as HomeAverageGoalKept format=decimal8.,
			sum(AwayGoalKept)/sum(Position="Away")as AwayAverageGoalKept format=decimal8.,

			
			sum(GoalConcede) as TotalGoalConcede,
			sum(HomeGoalConcede) as HomeGoalConcede,
			sum(AwayGoalConcede) as AwayGoalConcede,
			sum(GoalConcede)/count(*) as AverageGoalConcede format=decimal8.,
			sum(HomeGoalConcede)/sum(Position="Home") as HomeAverageGoalConcede format=decimal8.,
			sum(AwayGoalConcede)/sum(Position="Away")as AwayAverageGoalConcede format=decimal8.,

			sum(HomeFouls) as HomeFouls,
			sum(AwayFouls) as AwayFouls,
			sum(Fouls) as TotalFouls,
			sum(Fouls)/count(*) as AverageFouls format=decimal8.,
			sum(HomeFouls)/sum(Position="Home") as HomeAverageFouls format=decimal8.,
			sum(AwayFouls)/sum(Position="Away")as AwayAverageFouls format=decimal8.
	from work.Team
	group by Team;
quit;


data work.teamwin;
	set work.teamsummary;
 	label NOGame = "Number of Game"
 		NOHomeGame = "Number of Home Game"
		NOAwayGame = "Number of Away Game"
		NOWin = "Number of Win"
		HomeWinRate = "Home Win Rate"
		AwayWinRate = "Away Win Rate"
		WinRate = "Win Rate"
		AverageShots = "Average Shots"
		AverageFullTimeGoals ="Average Full Time Goals"
		TOST = "Total Shots on Target"
		HST = "Home Shots on target "
		AST = "Away Shots on target"
		AverageShotsOnTarget = "Average Shots On Target"
		HomeAverageShotsOnTarget = "Home Average Shots On Target"
		AwayAverageShotsOnTarget = "Away Average Shots On Target"
		
		GoalRateOnShotsOnTarget = "Goal Rate On Shots On Target"
		HomeGoalRateOnShotsOnTarget = "Home Goal Rate On Shots On Target"
		AwayGoalRateOnShotsOnTarget = "Away Goal Rate On Shots On Target"
		
		GoalRateOnShots = "Goal Rate On Shots"
		HomeGoalRateOnShots = "Home Goal Rate On Shots"
		AwayGoalRateOnShots = "Away Goal Rate On Shots"
		
		TotalGoalKept = "Total Goal Kept"
		AverageGoalKept = "Average Goal Kept"
		HomeAverageGoalKept = "Home Average Goal Kept"		
		AwayAverageGoalKept = "Away Average Goal Kept"

		TotalGoalConcede = "Total Goal Concede"
		AverageGoalConcede = "Average Goal Concede"
		HomeAverageGoalConcede = "Home Average Goal Concede"		
		AwayAverageGoalConcede = "Away Average Goal Concede"

		
		TotalFouls = "Total Fouls"
		AverageFouls = "Average Fouls"
		HomeAverageFouls = "Home Average Fouls"		
		AwayAverageFouls = "Away Average Fouls";
run;   

proc rank data=work.teamwin out=rankdes descending ties=low;
   var NOGame WinRate Homewinrate Awaywinrate AverageShotsOnTarget AverageShots GoalRateOnShotsOnTarget HomeGoalRateOnShotsOnTarget AwayGoalRateOnShotsOnTarget GoalRateOnShots HomeGoalRateOnShots AwayGoalRateOnShots AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept AverageGoalConcede HomeAverageGoalConcede AwayAverageGoalConcede AverageFouls HomeAverageFouls AwayAverageFouls;
   Ranks NOGameRank WinRateRank HomewinrateRank AwaywinrateRank AverageShotsOnTargetRank AverageShotsRank GoalRateOnShotsOnTargetRank HomeGoalRateOnShotsOnTargetRank AwayGoalRateOnShotsOnTargetRank GoalRateOnShotsRank HomeGoalRateOnShotsRank AwayGoalRateOnShotsRank AverageGoalKeptRank HomeAverageGoalKeptRank AwayAverageGoalKeptRank AverageGoalConcedeRank HomeAverageGoalConcedeRank AwayAverageGoalConcedeRank AverageFoulsRank HomeAverageFoulsRank AwayAverageFoulsRank;
run;

proc rank data=work.teamwin out=rankass ties=low;
   var NOGame WinRate Homewinrate Awaywinrate AverageShotsOnTarget AverageShots GoalRateOnShotsOnTarget HomeGoalRateOnShotsOnTarget AwayGoalRateOnShotsOnTarget GoalRateOnShots HomeGoalRateOnShots AwayGoalRateOnShots AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept AverageGoalConcede HomeAverageGoalConcede AwayAverageGoalConcede AverageFouls HomeAverageFouls AwayAverageFouls;
   Ranks NOGameRank WinRateRank HomewinrateRank AwaywinrateRank AverageShotsOnTargetRank AverageShotsRank GoalRateOnShotsOnTargetRank HomeGoalRateOnShotsOnTargetRank AwayGoalRateOnShotsOnTargetRank GoalRateOnShotsRank HomeGoalRateOnShotsRank AwayGoalRateOnShotsRank AverageGoalKeptRank HomeAverageGoalKeptRank AwayAverageGoalKeptRank AverageGoalConcedeRank HomeAverageGoalConcedeRank AwayAverageGoalConcedeRank AverageFoulsRank HomeAverageFoulsRank AwayAverageFoulsRank;
run;

data work.ranklabeldes;
	set work.rankdes;
	format AverageShotsOnTarget HomeAverageShotsOnTarget AwayAverageShotsOnTarget AverageShots HomeAverageShots AwayAverageShots AverageFouls HomeAverageFouls AwayAverageFouls AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept AverageFouls HomeAverageFouls AwayAverageFouls AverageFullTimeGoals 10.2;
	label NOGameRank ="Number of Game Rank"
		WinRateRank ="Win Rate Rank"
		HomewinrateRank ="Home win rate Rank"
		AwaywinrateRank ="Away win rate Rank" 
		AverageShotsOnTargetRank ="AverageShotsOnTargetRank"
		AverageShotsRank ="AverageShotsRank"
		GoalRateOnShotsOnTargetRank = "Goal Rate On Shots On Target Rank"
		HomeGoalRateOnShotsOnTargetRank ="Home Goal Rate On Shots On Target Rank" 
		AwayGoalRateOnShotsOnTargetRank ="Away Goal Rate On Shots On Target Rank"	
		GoalRateOnShotsRank ="Goal Rate On Shots Rank"
		HomeGoalRateOnShotsRank ="Home Goal Rate On Shots Rank"
		AwayGoalRateOnShotsRank ="Away Goal Rate On Shots Rank"
		AverageGoalKeptRank ="Average Goal Kept Rank"
		HomeAverageGoalKeptRank ="Home Average Goal Kept Rank"
		AwayAverageGoalKeptRank = "Away Average Goal Kept Rank"
		HomeAverageGoalConcedeRank ="Home Average Goal Concede Rank"
		AwayAverageGoalConcedeRank ="Away Average Goal Concede Rank"

		AverageFoulsRank ="Average Fouls Rank"
		HomeAverageFoulsRank ="Home Average Fouls Rank"
		AwayAverageFoulsRank = "Away Average Fouls Rank";
run;

data work.ranklabelass;
	set work.rankass;
	format AverageShotsOnTarget HomeAverageShotsOnTarget AwayAverageShotsOnTarget AverageShots HomeAverageShots AwayAverageShots AverageFouls HomeAverageFouls AwayAverageFouls AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept AverageFouls HomeAverageFouls AwayAverageFouls 10.2;
	label NOGameRank ="Number of Game Rank"
		WinRateRank ="Win Rate Rank"
		HomewinrateRank ="Home win rate Rank"
		AwaywinrateRank ="Away win rate Rank" 
		AverageShotsOnTargetRank ="AverageShotsOnTargetRank"
		AverageShotsRank ="AverageShotsRank"
		GoalRateOnShotsOnTargetRank = "Goal Rate On Shots On Target Rank"
		HomeGoalRateOnShotsOnTargetRank ="Home Goal Rate On Shots On Target Rank" 
		AwayGoalRateOnShotsOnTargetRank ="Away Goal Rate On Shots On Target Rank"	
		GoalRateOnShotsRank ="Goal Rate On Shots Rank"
		HomeGoalRateOnShotsRank ="Home Goal Rate On Shots Rank"
		AwayGoalRateOnShotsRank ="Away Goal Rate On Shots Rank"
		AverageGoalKeptRank ="Average Goal Kept Rank"
		HomeAverageGoalKeptRank ="Home Average Goal Kept Rank"
		AwayAverageGoalKeptRank = "Away Average Goal Kept Rank"
		
		HomeAverageGoalConcedeRank ="Home Average Goal Concede Rank"
		AwayAverageGoalConcedeRank ="Away Average Goal Concede Rank"
		AverageFoulsRank ="Average Fouls Rank"
		HomeAverageFoulsRank ="Home Average Fouls Rank"
		AwayAverageFoulsRank = "Away Average Fouls Rank";
run;
**********************************************************************;
**********************************************************************;
**********************************************************************;
**********************************************************************;
**********************************************************************;
/* the data could be used now */
/* report begin */
   
title1 "Report on EPL Results from 2010 to 2020";
title2 "The data is from 14 August 2010 to 26 July 2020 (10 Seasons)";
**********************************************************************;
/* Section A */
title3 "Section A - Descriptive Statistic by Season";

title4 "Summary Statistic by Season";
footnote1;

proc print data=WORK.SEASON label;
	var Season NOGame HomeWinRate AwayWinRate DrawRate AverageShots AverageShotsOnTarget AverageGoalKept AverageFouls;
run;

title1 "Number of Shots by Season";
footnote1 "2013-14 season has the largest number of shots, 2017-18 has the lowest number of shots.";
proc sgplot data=WORK.SEASON;
	vline Season / response=Shots datalabel;
	yaxis grid;
run;

title1 "Average Shots by Season";
footnote1 "The average shots is defined by the number of shots divided by the number of games.";
footnote2 "Home team has more shots than away team on average.";
proc sgplot data=WORK.SEASON;
	SERIES X = Season Y = AverageShots / datalabel;
	SERIES X = Season Y = HomeAverageShots / datalabel;
	SERIES X = Season Y = AwayAverageShots  / datalabel;
run;

title1 "Average Shots On Target by Season";
footnote1 "The average shots on target is defined by the number of shots on target divided by the number of games.";
footnote2 "Average shots on target is decreased after 2012-13.";
proc sgplot data=WORK.SEASON;
	SERIES X = Season Y = AverageShotsOnTarget / datalabel;
	SERIES X = Season Y = HomeAverageShotsOnTarget / datalabel;
	SERIES X = Season Y = AwayAverageShotsOnTarget / datalabel;
run;

title1 "Average Fouls by Season";
footnote1 "The average fouls is defined by the number of fouls divided by the number of games.";
proc sgplot data=WORK.SEASON;
	SERIES X = Season Y = AverageFouls / datalabel;
	SERIES X = Season Y = HomeAverageFouls / datalabel;
	SERIES X = Season Y = AwayAverageFouls / datalabel;
run;

title1 "Goal Rate On Shots by Season";
footnote1 "The goal rate on shots is defined by the number of goals divided by the number of shots.";
footnote2 " Goal rate on shots is the lowest at 2014-15 season";
proc sgplot data=WORK.SEASON;
	SERIES X = Season Y = GoalRateOnShots / datalabel;
	SERIES X = Season Y = HomeGoalRateOnShots / datalabel;
	SERIES X = Season Y = AwayGoalRateOnShots / datalabel;
run;

title1 "Average Goal Kept by Season";
footnote1 "The average goal kept is defined by the number of goal kept divided by the number of games.";
footnote2 "Average goal kept is decreased after 2012-13.";
proc sgplot data=WORK.SEASON;
	SERIES X = Season Y = AverageGoalKept / datalabel;
	SERIES X = Season Y = HomeAverageGoalKept / datalabel;
	SERIES X = Season Y = AwayAverageGoalKept / datalabel;
run;



**********************************************************************;
**********************************************************************;
**********************************************************************;
**********************************************************************;
title1 "Section B - Descriptive Statistic by Team";
title2 "Number of Game by Team";
footnote1 "This table represents the total number of game each team played, and the number they played at home and away seperately."; 
footnote2 "The number of game played at home and away is the same for each team.";
proc sort data=work.teamwin out=work.teamwin2;
   by descending NOGame;
run;

proc print data=work.teamwin2 label;
	var Team NOGame NOHomeGame NOAwayGame;
run;



title1 "Number of Win by Team";
footnote1;
proc sgplot data=WORK.TEAM;
	vbar Team / group=Wintype groupdisplay=stack datalabel;
	yaxis grid;
run;

data work.MC;
	set work.team;
	where team ="Manchester City";
run;



title1 "Average Shots by Team";
footnote1;
proc sgplot data=WORK.RANKLABELdes;
	vbar Team / response=AverageShots datalabel;
	yaxis grid;
run;

title1 "Average Shots On Target by Team";
footnote1;
proc sgplot data=WORK.RANKLABELdes;
	vbar Team / response=AverageShotsOnTarget datalabel;
	yaxis grid;
run;

title1 "Average Full Time Goals by Team";
footnote1;
proc sgplot data=WORK.RANKLABELdes;
	vbar Team / response=AverageFullTimeGoals datalabel;
	yaxis grid;
run;

title1 "Win Rate by Team";
footnote1 "The win rate is defined by the number of win divided by the number of game.";
footnote2 "The table is sorted by the win rate from highest to lowest.";
proc sort data=work.ranklabeldes out=work.rankorderdes;
   by descending WinRate;
run;

proc print data=work.rankorderdes label;
	var Team WinRate Homewinrate Homewinraterank Awaywinrate Awaywinraterank;
	format Homewinraterank Awaywinraterank BEST.;
run;

title1 "Goal Rate On Shots On Target";
footnote1 "The goal rate on shots on target is defined by the number of goals divided by the number of shots on target.";
footnote2;

proc sort data=work.ranklabeldes out=work.rankorderdes;
   by descending GoalRateOnShotsOnTarget;
run;

proc print data=work.rankorderdes label;
	var Team GoalRateOnShotsOnTarget HomeGoalRateOnShotsOnTarget HomeGoalRateOnShotsOnTargetRank AwayGoalRateOnShotsOnTarget AwayGoalRateOnShotsOnTargetRank;
	format AwayGoalRateOnShotsOnTargetRank BEST.;
run;


title1 "Goal Rate On Shots";
footnote1 "The goal rate on shots is defined by the number of goals divided by the number of shots.";
footnote2 "The table is sorted by the Goal Rate On Shots from highest to lowest.";

proc sort data=work.ranklabeldes out=work.rankorderdes;
   by descending GoalRateOnShots;
run;

proc print data=work.rankorderdes label;
	var Team GoalRateOnShots  HomeGoalRateOnShots HomeGoalRateOnShotsRank AwayGoalRateOnShots AwayGoalRateOnShotsRank;
	format HomeGoalRateOnShotsRank BEST.;

run;

title1 "Average Goal Kept by Each Team";
footnote1 "The average goal kept is defined by the number of goal kept divided by the number of games.";
footnote2 "Each team is listed by average goal kept from highest to lowest.";
proc sort data=work.ranklabeldes out=work.rankorderdes;
   by descending AverageGoalKept;
run;

proc print data=work.rankorderdes label;
	var Team  AverageGoalKept HomeAverageGoalKept HomeAverageGoalKeptRank AwayAverageGoalKept AwayAverageGoalKeptRank;
	format AwayAverageGoalKeptRank BEST.;
	format AverageGoalKept HomeAverageGoalKept AwayAverageGoalKept decimal10.2;
run;

title1 "Average Goal Concede by Each Team";
footnote1 "The average goal concede is represented by the average competitor team's goal.";
footnote2 "The table is sorted by the average goal concede from  lowest to highest.";

proc sort data=work.ranklabelass out=work.rankorderass;
   by AverageGoalConcede;
run;

proc print data=work.rankorderass label;
	var Team AverageGoalConcede HomeAverageGoalConcede HomeAverageGoalConcedeRank AwayAverageGoalConcede AwayAverageGoalConcedeRank;
	format AwayAverageGoalConcedeRank BEST.;
	format AverageGoalConcede HomeAverageGoalConcede AwayAverageGoalConcede decimal10.2;
run;


title1 "Average Fouls by Each Team";
footnote1 "The average fouls is defined by the number of fouls divided by the number of games.";
footnote2 "Each team is listed by average fouls from lowest to highest.";
proc sort data=work.ranklabelass out=work.rankorderass;
   by AverageFouls;
run;

proc print data=work.rankorderass label;
	var Team AverageFouls HomeAverageFouls HomeAverageFoulsRank AwayAverageFouls AwayAverageFoulsRank;
	format HomeAverageFoulsRank AwayAverageFoulsRank BEST.;
	format AverageFouls HomeAverageFouls AwayAverageFouls decimal10.2;
run;


title1 "Section C - Other Descriptive Statistic";

title2 "The Full Time Score Frequency";
footnote1;
footnote2;
proc sql;
	select Result,
			count(*) as Count,
			count(*)/3800 as Percentage format=percent8.2

	from work.eplresult
	group by Result
	order by Count desc;
quit;

title1 "Number of Game by Referee";
ods noproctitle;
proc freq data=work.EPLResult order=freq;
	ods output onewayfreqs=f;
	table referee / nocum norow nocol;
run;

data work.RefereeResult;
	set work.f;
	format Range $8.;
	if frequency <100 then do;
		Range = "<100";
		end;
	else if (frequency>=100 and frequency<=200) then do;
		Range = "100-200";
		end;
	else if frequency >200 then do;
		Range = ">200";
		end;
run;

title1 "Range of Number of Game by Referee";
footnote1 "There are more than 50% of referee has number of game less than 100 in 10 seasons.";
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=Range / stat=pct;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgrender template=SASStudio.Pie data=WORK.REFEREERESULT;
run;

ods graphics / reset;

title1 "Full Time Result";
footnote1 "About 46% of games are won by home team.";
proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=FTR2 / stat=pct;
		endlayout;
		endgraph;
	end;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgrender template=SASStudio.Pie data=WORK.EPLRESULT;
run;

ods graphics / reset;

**********************************************************************;
**********************************************************************;
/*Section C */

title1 "Section D - correlation and Regression Analysis";
title2 "correlation: Independent Variables and Win Rate";
footnote1 "Note: AverageFouls is not statistically significant at 95% confidence level.";
footnote2;

proc corr data=WORK.TEAMSUMMARY pearson outp=work.Corr_stats plots=none;
	var AverageShots AverageShotsOnTarget	AverageGoalKept AverageGoalConcede AverageFouls;
	with WinRate;
run;

title1 "Regression 1-1: Independent Variables and WinRate";
footnote1 "Note: AverageShots, AverageShotsOnTarget and AverageGoalKept are not statistically significant at 95% confidence level.";
footnote2;

proc reg data = work.rankorderdes;
	model WinRate = AverageShots AverageShotsOnTarget AverageGoalKept AverageGoalConcede AverageFouls;
run;

title1 "Regression 1-2: Independent Variables and WinRate";
footnote1 "Note: This is the final regression for WinRate, all independent variable are statistically significant.";
footnote2;

proc reg data = work.rankorderdes;
	model WinRate = AverageShotsOnTarget AverageGoalConcede AverageFouls;
run;

title1 "Correlation: Independent Variables and GameResult";
footnote1 "Note: GoalKept and Fouls is not statistically significant at 95% confidence level.";
footnote2;

proc corr data=WORK.TEAM pearson outp=work.Corr_stats plots=none;
	var Shot ShotOnTarget GoalKept GoalConcede Fouls;
	with GameResult;
run;

title1 "Regression 2-1: Independent Variables and GameResult";
footnote1 "Note: This is the final regression for GameResult, all independent variable are statistically significant.";
footnote2 "Both draw and lose are measured as 0, this regression is focusing on the factors that have effect on win.";
proc reg data = work.TEAM PLOTS(MAXPOINTS=NONE);
	model GameResult = Shot ShotOnTarget GoalKept GoalConcede Fouls;
run;

