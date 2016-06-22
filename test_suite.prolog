% To run these tests, fill in the pathname below and paste the command
% (without the %) into the Prolog console:
%
% consult("c:/Users/ian/Desktop/Classes/395 - KR for Game Characters/test_suite.prolog").
%
% To bring up the Prolog console, start the game and press F2. 

expect(Goal) :-
   Goal -> true
   ;
   begin(nl,
	 display("Expected "),
	 display(Goal),
	 displayln(" to be true.")).
  

expect(Goal, Var=ExpectedSolutions) :-
   all(Var, Goal, Solutions),
   (set_equal(Solutions, ExpectedSolutions) -> true
   ;
    begin(nl,
	  sort(ExpectedSolutions, ESorted),
	  sort(Solutions, SSorted),
	  display("In goal:"),
	  displayln(Goal),
	  display("Expected "),
	  displayln(Var=ESorted),
	  display("Got: "),
	  displayln(Var=SSorted))).

set_equal(A, B) :-
   subset(A, B),
   subset(B, A).

subset(A, B) :-
   forall(member(X, A),
	  member(X, B)).

test :-
   begin(test_kinds,
	 test_scooby_gang,
	 test_weasleys,
	 test_hogwarts,
	 test_anti_scoobies,
	 test_misc).

test_kinds :-
   begin(expect(kind_of(wizard, person))).

test_scooby_gang :-
   begin(expect(is_a(harry_potter, student)),
	 expect(is_a(harry_potter, person)),
	 expect(is_a(harry_potter, wizard)),
	 expect(related(harry_potter, bff, X),
		X=[ron_weasley, hermione_granger]),
	 expect(related(harry_potter, friend_of, X),
		X=[ron_weasley, hermione_granger]),
	 expect(related(ron_weasley, friend_of, hermione_granger)),
	 expect(related(hermione_granger, friend_of, ron_weasley)),
	 expect(related(X, member_of, dumbledores_army),
		X=[harry_potter, hermione_granger, ron_weasley, cho_chang,
		   fred_weasley, george_weasley, ginny_weasley,
		   angelina_johnson, lee_jordan, neville_longbottom,
		   luna_lovegood, padma_patil, parvati_patil]),
	 expect(related(harry_potter, leads, dumbledores_army))).

test_weasleys :-
   begin(expect(related(ron_weasley, brother, X),
		X=[fred_weasley, george_weasley, percy_weasley]),
	 expect(related(ron_weasley, sibling, X),
		X=[fred_weasley, george_weasley, percy_weasley,
		   ginny_weasley]),
	 expect(related(X, parent, molly_weasley),
		X=[ron_weasley, fred_weasley, george_weasley, percy_weasley,
		   ginny_weasley]),
	 expect(related(X, mother, molly_weasley),
		X=[ron_weasley, fred_weasley, george_weasley, percy_weasley,
		   ginny_weasley]),
	 expect(related(X, parent, arthur_weasley),
		X=[ron_weasley, fred_weasley, george_weasley, percy_weasley,
		   ginny_weasley]),
	 expect(related(X, father, arthur_weasley),
		X=[ron_weasley, fred_weasley, george_weasley, percy_weasley,
		   ginny_weasley]),
	 expect(is_a(molly_weasley, person)),
	 expect(is_a(molly_weasley, wizard))).

test_hogwarts :-
   begin(expect(related(X, member_of, gryffindor),
		X=[minerva_mcgonagall, harry_potter, ron_weasley,
		   hermione_granger, fred_weasley, george_weasley,
		   ginny_weasley, angelina_johnson, lee_jordan,
		   neville_longbottom, parvati_patil]),
	 expect(related(gryffindor, leader, X),
		X=[minerva_mcgonagall]),
	 expect(related(X, member_of, slytherin),
		X=[severus_snape, draco_malfoy, vincent_crabbe, gregory_goyle]),
	 expect(related(slytherin, leader, X),
		X=[severus_snape]),
	 expect(related(slytherin, leader, severus_snape)),
	 expect(is_a(X, teacher),
		X=[rubeus_hagrid, albus_dumbledore, minerva_mcgonagall,
		   horace_slughorn, severus_snape, filius_flitwick,
		   rolanda_hooch, pomona_sprout, remus_lupin, severus_snape,
		   sybil_trelawney])).

test_anti_scoobies :-
   begin(expect(related(gregory_goyle, friend_of, X),
		X=[draco_malfoy, vincent_crabbe]),
	 expect(related(X, friend_of, gregory_goyle),
		X=[draco_malfoy, vincent_crabbe])).

test_misc :-
   begin(expect(is_a(X, muggle),
		X=[dudley_dursley, vernon_dursley, petunia_dursley]),
	 expect(forall(is_a(X, teacher),
		       is_a(X, wizard))),
	 expect(forall(related(X, member_of, death_eaters),
		       is_a(X, wizard))),
	 expect(forall(is_a(X, teacher),
		       is_a(X, wizard))),
	 expect(forall(is_a(X, student),
		       is_a(X, wizard)))).

