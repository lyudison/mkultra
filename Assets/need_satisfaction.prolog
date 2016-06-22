%%%
%%% NEEDS AND SATISFYING ACTIONS/OBJECTS
%%%

%% satisfies(?Need, ?Object, ?Delta, ?Action)
%  True if performing Action at Object will increase satisfaction
%  of Need by Delta units.
satisfies(hunger, $refrigerator, 50, utter("Nom nom nom")).
satisfies(thirst, $desk, 50, utter("Glug glug glug")).
satisfies(thirst, $'kitchen table', 50, utter("Glug glug glug")).
satisfies(social, Character, 100, greet($me, Character)) :-
   character(Character),
   Character \= $me.
satisfies(fun, $radio, 60, utter("Listening to the radio")).
satisfies(bladder, $toilet, 100, utter("Excuse me; privacy, please?")).
satisfies(sleep, $bed, 100, utter("That's a comfy looking bed.")).
satisfies(sleep, $sofa, 100, utter("That's a comfy looking sofa")).
satisfies(hygiene, $'bathroom sink', 100, utter("Brush brush brush!")).

%%%
%%% TRACKING AND MODIFYING SATISFACTION LEVELS
%%%

%% satisfaction_level(+Need, -SatisfactionLevel)
%  Need is SatisfactionLevel percent satisfied.
satisfaction_level(Need, SatisfactionLevel) :-
   depletion_time(Need, DepletionTime),
   last_satisfied_time(Need, Time),
   SatisfactionLevel is max(0, 100*(1-(($now-Time)/DepletionTime))).

%% depletion_time(?NeedNanme, ?DepletionTime)
%  NeedName takes DepletionTime seconds to deplete.
depletion_time(hunger, 60).
depletion_time(thirst, 40).
depletion_time(sleep, 120).
depletion_time(bladder, 40).
depletion_time(hygiene, 120).
depletion_time(fun, 30).
depletion_time(social, 30).

% Increase satisfaction is actually written in Prolog, below.
% This just tells the planner it can call it.
strategy(increase_satisfaction(Need, Delta),
	 call(increase_satisfaction(Need, Delta))).

%% increase_satisfaction(+Need, +Delta)
%  IMPERATIVE
%  Updates Need to be Delta units more satisfied than before,
%  or 100% satisfied, whichever is lower.
increase_satisfaction(Need, Delta) :-
   depletion_time(Need, DepletionTime),
   satisfaction_level(Need, Level),
   NewLevel is min(100, Level+Delta),
   LastSatTime is $now-(DepletionTime*(1-(NewLevel/100))),
   assert(/needs/last_satisfied/Need: LastSatTime).

%% last_satisfied_time(+Need, -Time)
%  It's been Time seconds since Need was last satisfied.
last_satisfied_time(Need, Time) :-
   /needs/last_satisfied/Need:Time,
   !.
last_satisfied_time(_, 0).

%%%
%%% Reactive planner hooks
%%%

% If you just call say_string, it prints it but doesn't pause.
% so utter, pauses, waits a minimal amount of time, then waits
% futher if the character is still talking.
strategy(utter(String),
	 begin(say_string(String),
	       pause(1),
	       wait_condition(/perception/nobody_speaking))).

% Tells the everyday_life concern to try running satisfy_a_need if it
% doesn't have anything better to do.
todo(satisfy_a_need, 1).

%%%
%%% DEBUGGING TOOLS
%%%

fkey_command(alt-s, "Display satisfaction levels of player character") :-
   $pc::generate_overlay("Betsy's satisfaction levels",
			 satisfaction_level(Need, Level),
			 line(Need, "\t", Level)).

%%%
%%% Put your code below.
%%%
:- public increase_satisfaction/2.

strategy(satisfy_a_need,
	use_object(Need, Object)):-
	satisfies(Need, Object, _, _).

strategy(use_object(Need, Object),
	 begin(goto(Object),
	       Task,
	       increase_satisfaction(Need, Delta))) :-
	satisfies(Need, Object, Delta, Task).

strategy(resolve_conflict(satisfy_a_need, StrategyList),
	 use_object(Need, Object)) :-
	arg_max(use_object(Need, Object),
		Score,
		(member(use_object(Need, Object), StrategyList),
		 get_score(Need, Object, StrategyList, Score))).

get_score(Need, Object, StrategyList, Score) :-
    satisfies(Need, Object, Delta, _),
    sumall(Var,
           (member(use_object(Need_n, _), StrategyList),
            satisfaction_level(Need_n, Level_n),
            (Need_n=Need -> Var is 1/Level_n*min(100, Level_n+Delta)
                          ; Var is 1)),
           Score).
