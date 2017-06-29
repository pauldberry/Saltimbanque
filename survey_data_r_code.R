

require('sqldf')
require('survey')


final <- sqldf("select * from Cells05232016
               union all
               select * from Completes_05192016_Landlines_FINAL")

names(final) <- tolower(names(Cells05232016))

final <- final[final$ql != 2, ]

table(finalSql)

prop.table(table(finalSql))

small.svy.unweighted <- svydesign(ids=~1, data=final)

sex.dist <- data.frame(bin_gender = c('F', 'M', 'U'), Freq=nrow(final)*c(0.38, 0.54, 0.08))
race.dist <- data.frame(bin_race = c('W', 'O', 'B', 'H', 'A'), Freq=nrow(final)*c(0.53, 0.18, 0.16, 0.09, 0.04))
age.dist <- data.frame(bin_age = c('1', '2', '3', '4', '5'), Freq=nrow(final)*c(0.10, 0.24, 0.37, 0.06, 0.23))

weighted <- rake(design = small.svy.unweighted,
                 sample.margins = list(~bin_gender, ~bin_race, ~bin_age),
                 population.margins = list(sex.dist, race.dist, age.dist))

weighted <- trimWeights(weighted, lower=0,3, upper=3,
                         strict=TRUE)

final$weights <-weights(weighted)

write.csv(final, 'final.data.csv', na = '', row.names = F)