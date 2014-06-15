Notes on Implementation, and considerations.

* This implementation includes both the MinHashing and the LSH banding.
* An issue is that the dataset for this is way too small for realistic testing,
  so I created additional data. That can be found in the load_data DSL
  in main.rb. I commented out the additional entry to meet the requirements.
* Permutation is expensive to create, so I used a permutation polynomial. It
  has collision issues which I tried to minimize, and I do check for relevancy
  and reject those that have none at all.
* I created a small DSL to allow tweaking of the parameters.
* The permutation functions are ramdomly generated, and you may have
  to rerun the code with small datasets to see a better result in the
  recommendations.
* There were a few enhancements that could've been made to make this code
  more accurate, etc., but I considered them beyond the scope of this test.
* Overall, I found this to be a very interesting project, and I apologize for 
  taking a little extra time to get it right.



----

Hi.
Foreword: i hate it when I get some boiler plate task in interview applications so I'm trying to give our candidates something that will leave them with something useful for the future regardless of the outcome of the interview and you seemed like the kind of person that enjoys a challenge. That being said:

Let's talk recommendations.
You have a file:

    userId;productId
    1;12
    1;99
    1;32
    2;32
    2;77
    2;54
    2;66
    3;99
    3;42
    3;12
    3;32
    4;77
    4;66
    4;47
    5;65


Implement a reco engine with minhash that given a userId and his 
productList recommends 5 products from a similar user. 

* Extra points for sorting by similarity index. 
* Extra extra points for LSH bands.

Implementation can be minimal but needs to present some way to try it out. 

Please also provide a brief journal of what issues you encountered and how you fixed them(or at least what could be a possible solution).

Feel free to buzz me if you need clarification on anything or even if you want to discuss a certain aspect that you are having issues with. 
