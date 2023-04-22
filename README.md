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

According to Porr & Howell, the default tolerance is a tenth of the sampling rate as may be read in the Physionet comparison algorithms. 
For a 250 Hz sampling rate, a tolerance of 40 ms corresponds to (40e-3) * 250 = 10 samples.
The detection is said to be right shifted (Porr & Howell 2019) but our sample plots show some cases of left-shifted detection. So, we used a tolerance interval which is symmetrical around the reference annotation.
The WFBD application guide (WAG.pdf) says that the match window specifies the maximum absolute difference in annotation times that is permitted for matching annotations. Its default value used by the bxb function is 0.15 seconds which is way too large.

|   task    |  channel   | truepos | falsepos | falseneg  |  TPR   |   F1   |
|:---------:|:----------:|:-------:|:--------:|:---------:|:------:|:------:|
| hand_bike |   cable    | 0.9931  |  0.0069  |  0.00382  | 0.9962 | 0.9946 |
| hand_bike | cheststrap |  0.95   | 0.04997  |  0.03833  | 0.9615 | 0.9556 |
|  jogging  |   cable    | 0.9769  |  0.0231  |  0.04152  | 0.9607 | 0.9686 |
|  jogging  | cheststrap | 0.9532  | 0.04677  |  0.05882  | 0.9427 | 0.9478 |
|   maths   |   cable    | 0.9981  | 0.00193  | 0.0003936 | 0.9996 | 0.9988 |
|   maths   | cheststrap | 0.9857  | 0.01434  |  0.01405  | 0.9859 | 0.9858 |
|  sitting  |   cable    | 0.9989  | 0.00106  |     0     |   1    | 0.9995 |
|  sitting  | cheststrap | 0.9859  | 0.01415  |  0.01407  | 0.9859 | 0.9859 |
|  walking  |   cable    | 0.9942  | 0.005772 | 0.002409  | 0.9976 | 0.9959 |
|  walking  | cheststrap | 0.9709  | 0.02913  |  0.02814  | 0.9719 | 0.9714 |

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
| hand_bike |   cable    | 0.9918  | 0.008211 |  0.00513  | 0.9949 | 0.9933 |
| hand_bike | cheststrap | 0.9734  | 0.02663  |  0.01538  | 0.9841 | 0.9786 |
|  jogging  |   cable    |  0.961  | 0.03898  |  0.05668  | 0.946  | 0.9533 |
|  jogging  | cheststrap | 0.9691  | 0.03094  |  0.04309  | 0.9584 | 0.9636 |
|   maths   |   cable    | 0.9981  | 0.00193  | 0.0003936 | 0.9996 | 0.9988 |
|   maths   | cheststrap | 0.9662  | 0.03375  |  0.03347  | 0.9665 | 0.9664 |
|  sitting  |   cable    | 0.9989  | 0.00106  |     0     |   1    | 0.9995 |
|  sitting  | cheststrap |  0.968  |  0.032   |  0.03219  | 0.9678 | 0.9679 |
|  walking  |   cable    | 0.9837  | 0.01634  |  0.01312  | 0.9867 | 0.9852 |
|  walking  | cheststrap | 0.9676  | 0.03237  |  0.03139  | 0.9686 | 0.9681 |

  
    > library(rbenchmark)
    > benchmark(
    >     dtbr <- apply(sample_list, 1, valid_fn, freq_sampling = 250L,  slred = TRUE)
    > )
    > test replications  elapsed  relative  user.self  sys.self  user.child  sys.child
    >             100   776.02         1     299.06     27.72          NA         NA
    

![plot1 *rightend*]

[plot1 *rightend*]: 2ma_detection_1.png "Windows, blocks & annotations"


![plot2 *detail*]

[plot2 *detail*]: 2ma_detection_2.png "Windows, blocks & annotations"

    
