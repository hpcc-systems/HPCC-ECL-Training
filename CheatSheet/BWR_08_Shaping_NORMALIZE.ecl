/* NORMALIZE */
/*
  Break the contents of a record into
  normal form
*/
IMPORT Std;

InputLayout := RECORD
    UNSIGNED ride_id;
    STRING passenger_state; 
END;

inputDs := DATASET([{1, 'group cool talkative'},
               {2, 'calm quite'},
               {3, 'temper nasty'},
               {4, 'drunk smell'}], InputLayout);

 OutputLayout := RECORD
     UNSIGNED ride_id;
     STRING100 word;
 END;   

wordDs := NORMALIZE(inputDs, 
              STD.Str.WordCount(LEFT.passenger_state),
              TRANSFORM(OutputLayout, 
                        SELF.ride_id := LEFT.ride_id, 
                        SELF.word := STD.Str.ToUpperCase(
                            STD.Str.GetNthWord(LEFT.passenger_state, COUNTER))));     
OUTPUT(wordDs);       


