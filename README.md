# A two moving average qrs detector with optional temporal correction

* References

  * Elgendi, Mohamed; Eskofier, Björn; Dokos, Socrates; Abbott, Derek; Amaral, Luís A. Nunes. (2014): Revisiting QRS Detection Methodologies for Portable, Wearable, Battery-Operated, and Wireless ECG Systems. In PLoS ONE 9 (1), e84018. DOI: 10.1371/journal.pone.0084018.
  * Elgendi, Mohamed; Jonkman, Mirjam; Boer, Friso de (2009): Improved QRS Detection Algorithm using Dynamic Thresholds. In International Journal of Hybrid Information Technology 2, pp. 65–80.
  * Elgendi, Mohamed; Jonkman, Mirjam; DeBoer, Friso (Eds.) (2010): Frequency Bands Effects on QRS Detection. International Conference on Bio-inspired Systems and Signal Processing.
  * Elgendi, Mohamed; Talkachova, Alena (2013): Fast QRS Detection with an Optimized Knowledge-Based Method. Evaluation on 11 Standard ECG Databases. In PLoS ONE 8 (9), e73557. DOI: 10.1371/journal.pone.0073557.
  * Gradl, Stefan; Leutheuser, Heike; Elgendi, Mohamed; Lang, Nadine; Eskofier, Bjoern M. (2015): Temporal correction of detected R-peaks in ECG signals. A crucial step to improve QRS detection algorithms. In Annual International Conference of the IEEE Engineering in Medicine and Biology Society. IEEE Engineering in Medicine and Biology Society. Annual International Conference 2015, pp. 522–525. DOI: 10.1109/embc.2015.7318414.
  * Porr, Bernd; Howell, Luis (2019): R-peak detector stress test with a new noisy ECG database reveals significant performance differences amongst popular detectors: Cold Spring Harbor Laboratory.

# Validation against the Glasgow University Database (GUDB)
All recordings with annotations were tested: 123 for the chest strap and 106 for the loose cable setup.

* With no slackness correction
  * With zero tolerance

|   task    |  channel   | truepos | falsepos | falseneg |  TPR   |   F1   |
|:---------:|:----------:|:-------:|:--------:|:--------:|:------:|:------:|
| hand_bike |   cable    |  0.345  |  0.655   |  0.6542  | 0.3453 | 0.3451 |
| hand_bike | cheststrap | 0.3219  |  0.6781  |  0.6747  | 0.3233 | 0.3226 |
|  jogging  |   cable    | 0.2726  |  0.7274  |  0.7339  | 0.2703 | 0.2715 |
|  jogging  | cheststrap | 0.2849  |  0.7151  |  0.7203  | 0.2824 | 0.2836 |
|   maths   |   cable    | 0.3481  |  0.6519  |  0.6513  | 0.3484 | 0.3483 |
|   maths   | cheststrap | 0.4021  |  0.5979  |  0.5977  | 0.4022 | 0.4022 |
|  sitting  |   cable    | 0.3392  |  0.6608  |  0.6606  | 0.3393 | 0.3393 |
|  sitting  | cheststrap | 0.3925  |  0.6075  |  0.6078  | 0.3922 | 0.3924 |
|  walking  |   cable    | 0.2902  |  0.7098  |  0.7092  | 0.2903 | 0.2902 |
|  walking  | cheststrap | 0.3503  |  0.6497  |  0.6495  | 0.3504 | 0.3504 |
  * With a 40 ms tolerance
   
For a 250 Hz sampling rate, a tolerance of 40 ms corresponds to (40e-3) * 250 = 10 samples i.e. ref. annotation +/- 5 samples.
The detection is said to be right shifted (Porr & Howell 2019) but our sample plots # show some cases of left-shifted detection. So, we used a tolerance interval which is symmetrical around the reference annotation.

|   task    |  channel   | truepos | falsepos | falseneg |  TPR   |   F1   |
|:---------:|:----------:|:-------:|:--------:|:--------:|:------:|:------:|
| hand_bike |   cable    | 0.9165  | 0.08349  | 0.08042  | 0.9196 | 0.918  |
| hand_bike | cheststrap | 0.7222  |  0.2778  |  0.2704  | 0.7284 | 0.7252 |
|  jogging  |   cable    | 0.8731  |  0.1269  |  0.1409  | 0.8624 | 0.8676 |
|  jogging  | cheststrap |  0.646  |  0.354   |  0.3651  | 0.637  | 0.6414 |
|   maths   |   cable    | 0.9156  | 0.08439  | 0.08264  | 0.9174 | 0.9165 |
|   maths   | cheststrap | 0.7607  |  0.2393  |  0.239   | 0.761  | 0.7609 |
|  sitting  |   cable    | 0.8797  |  0.1203  |   0.12   |  0.88  | 0.8799 |
|  sitting  | cheststrap | 0.7417  |  0.2583  |  0.2585  | 0.7415 | 0.7416 |
|  walking  |   cable    | 0.8725  |  0.1275  |  0.1245  | 0.8755 | 0.874  |
|  walking  | cheststrap | 0.7221  |  0.2779  |  0.2774  | 0.7225 | 0.7223 |

* Using slackness correction

  * With zero tolerance

|   task    |  channel   | truepos | falsepos | falseneg  |  TPR   |   F1   |
|:---------:|:----------:|:-------:|:--------:|:---------:|:------:|:------:|
| hand_bike |   cable    | 0.9896  | 0.01043  | 0.007352  | 0.9926 | 0.9911 |
| hand_bike | cheststrap |  0.972  | 0.02801  |  0.01681  | 0.9826 | 0.9772 |
|  jogging  |   cable    | 0.9556  | 0.04441  |  0.06194  | 0.9408 | 0.948  |
|  jogging  | cheststrap |  0.965  | 0.03502  |  0.04708  | 0.9545 | 0.9596 |
|   maths   |   cable    | 0.9979  | 0.002148 | 0.0006106 | 0.9994 | 0.9986 |
|   maths   | cheststrap | 0.9662  | 0.03375  |  0.03347  | 0.9665 | 0.9664 |
|  sitting  |   cable    | 0.9989  | 0.00106  |     0     |   1    | 0.9995 |
|  sitting  | cheststrap |  0.967  |  0.033   |  0.0332   | 0.9668 | 0.9669 |
|  walking  |   cable    | 0.9819  | 0.01807  |  0.01486  | 0.985  | 0.9834 |
|  walking  | cheststrap | 0.9668  | 0.03321  |  0.03223  | 0.9678 | 0.9673 |

  * With a 40 ms tolerance
   
|   task    |  channel   | truepos | falsepos | falseneg  |  TPR   |   F1   |
|:---------:|:----------:|:-------:|:--------:|:---------:|:------:|:------:|
| hand_bike |   cable    | 0.9904  | 0.009567 | 0.006487  | 0.9935 | 0.992  |
| hand_bike | cheststrap | 0.9731  |  0.0269  |  0.01565  | 0.9838 | 0.9783 |
|  jogging  |   cable    | 0.9582  | 0.04177  |  0.05935  | 0.9434 | 0.9506 |
|  jogging  | cheststrap | 0.9677  | 0.03229  |  0.0444   | 0.9571 | 0.9623 |
|   maths   |   cable    | 0.9979  | 0.002148 | 0.0006106 | 0.9994 | 0.9986 |
|   maths   | cheststrap | 0.9662  | 0.03375  |  0.03347  | 0.9665 | 0.9664 |
|  sitting  |   cable    | 0.9989  | 0.00106  |     0     |   1    | 0.9995 |
|  sitting  | cheststrap |  0.968  |  0.032   |  0.03219  | 0.9678 | 0.9679 |
|  walking  |   cable    | 0.9826  | 0.01736  |  0.01415  | 0.9857 | 0.9842 |
|  walking  | cheststrap | 0.9676  | 0.03237  |  0.03139  | 0.9686 | 0.9681 |

    > library(rbenchmark)
    > benchmark(
    >     dtbr <- apply(sample_list, 1, valid_fn, freq_sampling = 250L,  slred = TRUE)
    > )
    > test replications  elapsed  relative  user.self  sys.self  user.child  sys.child
    >             100   776.02         1     299.06     27.72          NA         NA
