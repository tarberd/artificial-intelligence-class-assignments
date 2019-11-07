pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- !check_for_resources.
   
+found(R)
   :  my_pos(X, Y) & not there_is_resource_at(R, X, Y)
   <- +there_is_resource_at(R, X, Y);
   	  .print("I found resource (", R, ") at (", X, ", ", Y, ") ,telling others!");
   	  .my_name(My_name);
   	  .all_names(All_names);
   	  .delete(builder, All_names, All_names_less_builder);
   	  .delete(My_name, All_names_less_builder, All_names_less_builder_less_myself);
   	  for( .member(Agent, All_names_less_builder_less_myself) )
   	  {
   	  	.send(Agent, tell, there_is_resource_at(R, X, Y));
   	  }.
     
+!check_for_resources
   :  resource_needed(R) & found(R)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.

+!check_for_resources
   :  resource_needed(R) & not found(R)
   <- .wait(100);
      !check_for_resources_found_by_others(R).
   	  
+!check_for_resources_found_by_others(R) 
   :  there_is_resource_at(R, X, Y) <- 
   -checking_cells;
   +pos(maybe, X, Y);
   !go(maybe);
   -pos(maybe, X, Y);
   +checking_cells;
   if(not found(R)){
   	  .abolish(there_is_resource_at(R, X, Y));
   	  !tell_others_there_is_no_more_resource_at(R, X, Y);
   }
   !check_for_resources.
   
+!tell_others_there_is_no_more_resource_at(R, X, Y)
   : true 
   <- 
   	  .my_name(My_name);
   	  .all_names(All_names);
   	  .delete(builder, All_names, All_names_less_builder);
   	  .delete(My_name, All_names_less_builder, All_names_less_builder_less_myself);
   	  for( .member(Agent, All_names_less_builder_less_myself) )
   	  {
   	  	.send(Agent, achieve, remove_there_is_resource_at(R, X, Y));
   	  }.
   	  
+!remove_there_is_resource_at(R, X, Y) : true <- .abolish(there_is_resource_at(R, X, Y)).

+!check_for_resources_found_by_others(R) 
   :  not there_is_resource_at(R, X, Y) 
   <- move_to(next_cell).

+!stop_checking : true
   <- ?my_pos(X,Y);
      +pos(back,X,Y);
      -checking_cells.

+!take(R,B) : true
   <- .wait(100);
   	  mine(R);
      !go(B);
      drop(R).

+!continue_mine : true
   <- 
      ?pos(back, X, Y);
      if(there_is_resource_at(R, X, Y)){
      	!go(back);
      }
      -pos(back,X,Y);
      +checking_cells;
      if(not found(R)){
   	  	.abolish(there_is_resource_at(R, X, Y));
   	  	!tell_others_there_is_no_more_resource_at(R, X, Y);
   	  }
      !check_for_resources.

+!go(Position) 
   :  pos(Position,X,Y) & my_pos(X,Y)
   <- true.

+!go(Position) : true
   <- ?pos(Position,X,Y);
      .wait(100);
      move_towards(X,Y);
      !go(Position).

@psf[atomic]
+!search_for(NewResource) : resource_needed(OldResource)
   <- +resource_needed(NewResource);    
      -resource_needed(OldResource).

@pbf[atomic]
+building_finished : true
   <- .drop_all_desires;
      !go(boss).
      
