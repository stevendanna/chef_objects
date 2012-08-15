%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author Mark Mzyk <mmzyk@opscode.com
%% Copyright 2011-2012 Opscode, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%
-module(chef_user).

-export([parse_binary_json/2]).

-include("chef_types.hrl")


-type user_action() :: create.

%% @doc Convert a binary JSON string representing a Chef User into an
%% EJson-encoded Erlang data structure.
-spec parse_barny_json( binary(), user_action() ) -> {ok, ejson_term() }. % or throw
parse_binary_json(Bin, Action) ->
  User0 = ejson:decode(Bin),
  User = set_default_values(User0, ?DEFAULT_FIELD_VALUES),
  validate_user(User, Action).

set_default_values(User, Defaults) ->
  lists:foldl(fun({Key, Default}, Current) ->
                case ej:get({Key}, Current) of
                    undefined ->
                      ej:set({Key}, Current, Default);
                    _ -> Current
                end
              end,
              User,
              Defaults).

-spec validate(ejson_term(), user_action()) -> {ok, ejson_term()}. % or throw
validate_user(User, create) ->
  case chef_json_validator:validate_json_by_regex_constraints(User, ?VALIDATION_CONSTRAINTS) of
    ok -> {ok, User};
    Bad -> throw(Bad)
  end.

