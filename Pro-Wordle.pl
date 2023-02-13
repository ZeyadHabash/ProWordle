% supressing warnings by declaring these predicates as dynamic
:-dynamic word/2.
:-dynamic is_category/1.

% Succeeds if L is a list containing all available categories with no duplicates
categories(L):- setof(Y,is_category(Y),L).

% Succeeds if L is the length of a word present in the KB
available_length(L):- 
    word(X,_),
    atom_length(X,L).

% Succeeds if W is a word in the KB, L is its length and C is its category
pick_word(W,L,C):-
    word(W,C), atom_length(W,L).

% Succeeds if CL is the intersection of L1 & L2 (CL contains the elements present in both lists)
correct_letters(L1,L2,CL):-
    intersection(L2,L1,CL1),
    list_to_set(CL1,CL).

% Succeeds if CP is the list containing the letters which are present in the same positions in L1 & L2
correct_positions(_,[],[]).
correct_positions(L1,L2,CP):-
    L1 = [H1|T1], L2 = [H2|T2], H1==H2, !, CP = [H1|T3], correct_positions(T1,T2,T3).
 correct_positions(L1,L2,CP):-
    L1 = [_|T1], L2 = [_|T2],
    correct_positions(T1,T2,CP).


% The KB building phase. Prompts the user to enter a word and its category and adds them to the KB. Stops when “done.” is entered.
build_kb:-
    write('Please enter a word and its category on separate lines:'), nl,
    read(X),
    (
        nonvar(X),
        (   X = done, write('Done building the words database...'), nl,nl; 
            nl,
            read(Y),
            (
                nonvar(Y),    
                assert(word(X,Y)),
                assert(is_category(Y)),
                build_kb;
                write('Please enter word in lowercase'), nl,
                build_kb
            )
        );
        write('Please enter word in lowercase'), nl, 
        build_kb
    ).


% Prompts the user to enter a category C. Succeeds if user input is a category in the KB; if it is not, prompts the user to enter another category.
choose_category(C):-  
    write('Choose a category:'), nl,
    read(C1), nl,
    (
        \+is_category(C1), write('This category does not exist. '), nl,
        choose_category(C2), C = C2;
        is_category(C1), C = C1
    ).

% Prompts the user to enter a length L. Succeeds if a word of the length L exists in the pre-chosen category C; if it does not, prompts the user to enter another length.
choose_length(L,C):-
    write('Choose a length: '), nl,
    read(L1), nl, 
    (
        number(L1),
        (
            \+pick_word(_,L1,C), write('There are no words of this length. '), nl,
            choose_length(L2,C), L = L2;
            pick_word(_,L1,C), L = L1
        );
        \+number(L1),
        (
            atom_length(L1, L1_length), 
            \+pick_word(_,L1_length,C), write('There are no words of this length. '), nl,
            choose_length(L2,C), L = L2;
            pick_word(_,L1_length,C), L = L1_length
        )
    ).
% if the player has no guesses left he loses
guess(_,_,0):- write('You Lost! ;-;').

guess(W,L,G):- 
    write('Enter a word composed of '), write(L), write(' letters:'), nl,
    read(X), nl,
    (
        % check if word X is present in KB
        \+word(X,_), write('Word not present in KB. Try again.'), nl, write('Remaining Guesses are '), write(G), nl, guess(W,L,G); 

        % check if word X contains L letters
        \+atom_length(X, L), write('Word is not composed of '), write(L), write(' letters. Try again.'), nl,
        write('Remaining Guesses are '), write(G), nl,  guess(W,L,G);

        % Turn entered word X into a list of letters XList and pre-picked word W into a list of letters WList
        atom_length(X,L), atom_chars(X, XList), atom_chars(W,WList),
        
        % store the correct letters from XList in CL and letters in correct positions in CP
        correct_letters(XList,WList,CL), correct_positions(XList,WList,CP),
        (
            % if the length of the correct positions CP is the same as the length of the pre-picked word WList then the guessed word is correct and the player won
            length(WList,WLength), length(CP,WLength), write('You Won! ^-^ :3');
            write('Correct letters are: '), write(CL) , nl,
            write('Correct letters in correct positions are: '), write(CP),nl,
            GLeft is G-1,
            (
                GLeft == 0;
                write('Remaining Guesses are '), write(GLeft), nl
            ),
            guess(W,L,GLeft)
        )
    ).



% The gameplay phase. Displays available categories, prompts the user to choose a category and a length of a word from said category. Initiates gameplay start and displays number of guesses. (done through using the predicates choose_category/1, choose_length/2, pick_word/3, guess/3)
play:-
    write('The available categories are: '),
    categories(Categories),
    write(Categories), nl,
    choose_category(C), choose_length(L,C),
    G is L+1, 
    write('Game started. You have '), write(G), write(' guesses. '), nl,
    pick_word(W,L,C),
    guess(W,L,G).


% Welcomes the player into the game, initiates the KB build phase then the gameplay phase. (done through using the predicates build_kb/0, play/0)
main:- 
    write('Welcome to Pro-Wordle!'), nl,
    write('----------------------'), nl, nl,
    build_kb, 
    play.



