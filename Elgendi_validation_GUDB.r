
# Validation against the Glasgow University Database (GUDB)
# all recordings with annotations were tested: 123 for the chest strap and 
# 106 for the loose cable setup.

require("pander")
source("qrs_detector_2ma_mod.r")

task <- c("hand_bike", "jogging", "maths", "sitting", "walking")

sample_list <- data.table(task = rep(rep(task, 25), 2), 
    subj = rep(formatC(rep(0:24, each = 5), 1, flag = "0"), 2))
sample_list[, channel := rep(c("cheststrap", "cable"), each = 125)]

repert <- "D:/.../GUDB/dataset_716/experiment_data"

# a function that will import ecg and annotation datasets then detect qrs peaks
# Only two parameters may be changed (sampling rate and slackness reduction)
# see the qrs detector function for further options
valid_fn <-  function(x, freq_sampling, slred) { 
annot_cs <- file.path(repert, paste0("subject_", x[2]), x[1], "annotation_cs.tsv")
annot_cable <- file.path(repert, paste0("subject_", x[2]), x[1], "annotation_cables.tsv") 
annot_path <- fifelse(x["channel"] == "cheststrap", annot_cs, annot_cable)
col_no <- fifelse(x["channel"] == "cheststrap", 1L, 2L)

if (file.exists(annot_path)) {
dt_annot <- fread(file = annot_path, col.names = "annotation") 
dt_annot <- data.table(task = x["task"], subj = x["subj"], channel = x["channel"], 
dt_annot)
dt_annot[, annot_nb := seq_along(annotation)]
}  else {
    dt_annot <- NULL
}
ecg_path <- file.path(repert, paste0("subject_", x[2]), x[1], "ECG.tsv")
if (file.exists(ecg_path) && !is.null(dt_annot)) {
    ecg_dat <- fread(file = ecg_path)

    dt_qrs <- ma_detector(signal = 1000 * ecg_dat[[col_no]], srate = freq_sampling, slackness_red = slred)
    if(slred) {
        dt_qrs[, loc := loc_sr][, loc_sr := NULL]
    }
    dt_loc <- data.table(task = x["task"], subj = x["subj"], channel = x["channel"], 
    dt_qrs[!is.na(loc), .(loc)])
    dt_loc[, truepos := loc %in% dt_annot[, annotation]][, falsepos := as.logical(1 - truepos)]
    dt_annot[, falseneg := !(annotation %in% dt_loc[, loc])]
} else {
    dt_qrs <- dt_loc <- dt_annot <- NULL
}
list(dt_annot, dt_loc, dt_qrs)
}

# library(rbenchmark)
# benchmark(
#     dtbr <- apply(sample_list, 1, valid_fn, freq_sampling = 250L,  slred = TRUE)
# )
# test replications  elapsed  relative  user.self  sys.self  user.child  sys.child
#               100   776.02         1     299.06     27.72          NA         NA



#***************** without slackness correction *****************************
system.time(
dtbr <- apply(sample_list, 1, valid_fn, freq_sampling = 250L,  slred = FALSE)
)

#---------------- validation using zero tolerance ----------------------------
expected <- do.call(rbind, lapply(dtbr, function(x) x[[1]]))
calc <- do.call(rbind, lapply(dtbr, function(x) x[[2]]))

V <- copy(calc)
V <- V [expected, on = .(task, channel, subj, loc == annotation), loc := NA]
V <- V[, .(truepos = sum(is.na(loc)) / .N, falsepos = sum(!is.na(loc)) / .N), by = .(task, channel, subj)]

W <- expected[calc, on = .(task, channel, subj, annotation == loc), annotation := NA]
W <- W[, .(falseneg = sum(!is.na(annotation)) / .N), by = .(task, channel, subj)]

calc_exp <- merge(V, W, by = c("task", "channel", "subj"), all = TRUE)
# true positives are named preciion in this context
# TPR stands for "true positive rate", syn. recall, sensitivity
calc_exp[, `:=`(TPR = truepos / (truepos + falseneg), F1 = (2 * truepos) / (2 * truepos + falsepos + falseneg))]
calc_exp
mycols <- names(calc_exp[, truepos:F1])
# calc_exp[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")]
pander::pandoc.table(calc_exp[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")], style = "rmarkdown")
# ---------------------------------------------------------------

#----------------allowing a tolerance tolr --------------------------

# According to Porr & Howell, the default tolerance is a tenth of the 
# sampling rate as may be read in the Physionet comparison algorithms. 
# a tolerance of 40ms corresponds to (10e-2)*250 = 10 samples i.e. ref. annotation +/- 5 samples.
# The detection is said to be right shifted (Porr & Howell 2019) but our sample plots
# show some cases of left-shifted detection. So, we used an tolerance interval
# which is symmetrical around the reference annotation.
expected <- do.call(rbind, lapply(dtbr, function(x) x[[1]]))
calc <- do.call(rbind, lapply(dtbr, function(x) x[[2]]))

tolr <- 5 # tolerance expressed as the nb of samples each side of the reference annotation
calc[, `:=`(start = loc - tolr, end = loc + tolr)]
setkey(calc, task, channel, subj, start, end)
expected[, `:=`(start = annotation, end = annotation)]
setkey(expected, task, channel, subj, start, end)
# calc in expected
expected_calc <- foverlaps(expected, calc, type = "within")
# get false negatives
fn <- expected_calc[, .(falseneg = sum(is.na(loc)) / .N), by = .(task, channel, subj)]
# expected in calc
calc_expected <- foverlaps(calc, expected, type = "any")
# get true and false positives
tp <- calc_expected[, .(truepos = sum(!is.na(annotation)) / .N, falsepos = sum(is.na(annotation)) / .N), 
by = .(task, channel, subj)]
tpfn <- merge(tp, fn)
# true positives are named preciion in this context
# TPR stands for "true positive rate", syn. recall, sensitivity
tpfn[, `:=`(TPR = truepos / (truepos + falseneg), F1 = (2 * truepos) / (2 * truepos + falsepos + falseneg))]
tpfn
mycols <- names(tpfn[, truepos:F1])
# simplermarkdown::md_table(tpfn[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")])

pander::pandoc.table(tpfn[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")], style = "rmarkdown")
# ---------------------------------------------------------------


#***************** with slackness correction *****************************
system.time(
dtbr <- apply(sample_list, 1, valid_fn, freq_sampling = 250L,  slred = TRUE)
)

#---------------- validation using zero tolerance ----------------------------
expected <- do.call(rbind, lapply(dtbr, function(x) x[[1]]))
calc <- do.call(rbind, lapply(dtbr, function(x) x[[2]]))

V <- copy(calc)
V <- V [expected, on = .(task, channel, subj, loc == annotation), loc := NA]
V <- V[, .(truepos = sum(is.na(loc)) / .N, falsepos = sum(!is.na(loc)) / .N), by = .(task, channel, subj)]

W <- expected[calc, on = .(task, channel, subj, annotation == loc), annotation := NA]
W <- W[, .(falseneg = sum(!is.na(annotation)) / .N), by = .(task, channel, subj)]

calc_exp <- merge(V, W, by = c("task", "channel", "subj"), all = TRUE)
# true positives are named preciion in this context
# TPR stands for "true positive rate", syn. recall, sensitivity
calc_exp[, `:=`(TPR = truepos / (truepos + falseneg), F1 = (2 * truepos) / (2 * truepos + falsepos + falseneg))]
calc_exp
mycols <- names(calc_exp[, truepos:F1])
# calc_exp[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")]
pander::pandoc.table(calc_exp[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")], style = "rmarkdown")
# ---------------------------------------------------------------

#----------------allowing a tolerance tolr --------------------------

# According to Porr & Howell, the default tolerance is a tenth of the 
# sampling rate as may be read in the Physionet comparison algorithms. 
# a tolerance of 40ms corresponds to (10e-2)*250 = 10 samples i.e. ref.annotation +/- 5 samples.
expected <- do.call(rbind, lapply(dtbr, function(x) x[[1]]))
calc <- do.call(rbind, lapply(dtbr, function(x) x[[2]]))

tolr <- 5 # tolerance expressed as the nb of samples each side of the reference annotation
calc[, `:=`(start = loc - tolr, end = loc + tolr)]
setkey(calc, task, channel, subj, start, end)
expected[, `:=`(start = annotation, end = annotation)]
setkey(expected, task, channel, subj, start, end)
# calc in expected
expected_calc <- foverlaps(expected, calc, type = "within")
# get false negatives
fn <- expected_calc[, .(falseneg = sum(is.na(loc)) / .N), by = .(task, channel, subj)]
# expected in calc
calc_expected <- foverlaps(calc, expected, type = "any")
# get true and false positives
tp <- calc_expected[, .(truepos = sum(!is.na(annotation)) / .N, falsepos = sum(is.na(annotation)) / .N), 
by = .(task, channel, subj)]
tpfn <- merge(tp, fn)
# true positives are named preciion in this context
# TPR stands for "true positive rate", syn. recall, sensitivity
tpfn[, `:=`(TPR = truepos / (truepos + falseneg), F1 = (2 * truepos) / (2 * truepos + falsepos + falseneg))]
tpfn
mycols <- names(tpfn[, truepos:F1])
# simplermarkdown::md_table(tpfn[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")])

pander::pandoc.table(tpfn[, lapply(.SD, mean), .SDcols = mycols, by = c("task", "channel")], style = "rmarkdown")
# ---------------------------------------------------------------


#*************************************************************************
