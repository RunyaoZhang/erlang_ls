-module(els_rename_SUITE).

-include("erlang_ls.hrl").

%% CT Callbacks
-export([ suite/0
        , init_per_suite/1
        , end_per_suite/1
        , init_per_testcase/2
        , end_per_testcase/2
        , groups/0
        , all/0
        ]).

%% Test cases
-export([ rename_behaviour_callback/1 ]).

%%==============================================================================
%% Includes
%%==============================================================================
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

%%==============================================================================
%% Types
%%==============================================================================
-type config() :: [{atom(), any()}].

%%==============================================================================
%% CT Callbacks
%%==============================================================================
-spec suite() -> [tuple()].
suite() ->
  [{timetrap, {seconds, 30}}].

-spec all() -> [{group, atom()}].
all() ->
  [{group, tcp}, {group, stdio}].

-spec groups() -> [atom()].
groups() ->
  els_test_utils:groups(?MODULE).

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
  els_test_utils:init_per_suite(Config).

-spec end_per_suite(config()) -> ok.
end_per_suite(Config) ->
  els_test_utils:end_per_suite(Config).

-spec init_per_testcase(atom(), config()) -> config().
init_per_testcase(TestCase, Config) ->
  els_test_utils:init_per_testcase(TestCase, Config).

-spec end_per_testcase(atom(), config()) -> ok.
end_per_testcase(TestCase, Config) ->
  els_test_utils:end_per_testcase(TestCase, Config).

%%==============================================================================
%% Testcases
%%==============================================================================
-spec rename_behaviour_callback(config()) -> ok.
rename_behaviour_callback(Config) ->
  Uri = ?config(rename_uri, Config),
  Line = 2,
  Char = 9,
  NewName = <<"new_awesome_name">>,
  #{result := Result} = els_client:document_rename(Uri, Line, Char, NewName),
  Expected =  #{changes =>
                  #{ binary_to_atom(Uri, utf8) =>
                       [ #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 19, line => 2}
                               , start => #{character => 10, line => 2}}}
                       ]
                   , binary_to_atom(?config(rename_usage1_uri, Config), utf8) =>
                       [ #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 18, line => 4}
                               , start => #{character => 9, line => 4}}}
                       , #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 9, line => 7}
                               , start => #{character => 0, line => 7}}}
                       , #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 9, line => 9}
                               , start => #{character => 0, line => 9}}}
                       , #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 15, line => 6}
                               , start => #{character => 6, line => 6}}}
                       ]
                   , binary_to_atom(?config(rename_usage2_uri, Config), utf8) =>
                       [ #{ newText => NewName
                          , range =>
                              #{ 'end' => #{character => 18, line => 4}
                               , start => #{character => 9, line => 4}}}
                       , #{ newText => NewName
                          , range =>
                             #{ 'end' => #{character => 9, line => 6}
                              , start => #{character => 0, line => 6}}}
                       ]
                   }
               },
  ?assertEqual(Expected, Result).
