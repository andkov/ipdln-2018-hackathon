

This is an approxinate script of the presentation given at the end of the hackathon (2018-09-14). 

# Hackathon results - Group 4


If any of you were at my talk on Wednesday, you already know that I am a big proponent of using data science techniques in health research, and of reproducible and transparent analyses. When our group met on Monday, we realized that we all share this interest. So due to the quick nature of this hackathon, we decided do something a little bit unconventional, we wanted to focus on how we looked at the data, and worry less about what we find in it.

We therefore want to start by pointing you to the public GitHub repo that houses all of the code ( but not the data- for that you’ll have to request access from Statistics Canada).


We wanted to visualize logistic regression. We fit a binomial logistic regression model described at the top of the screen, with mortality as the outcome, then we asked the model to generate predicted values based on predictor levels. To aid attention of the analyst, we mapped predictor levels on to colors that capture our informed expectation of the effect the predictor has on mortality. We are using a graphing technique to further explore the results. On the Y axis we have probability of survival at X years. On the X axis is age group represented by the floor of their 5 year age group, slightly jittered to enhance visibility. To look at the results in closer detail we will use a coloring book technique.


We start with no color on the canvas. We have associated each level of the predictor with an informed expectation about its effect on mortality. We associated risk with color temperature; higher risk represented by warmer hues (red and orange), while decreased risk by cooler hues, blue and purple. Reference group is represented by neutral green.
...


We sought to investigate how language, whether or not an immigrant speaks English, French, neither or both, influences their mortality, and whether this effect varies across provinces. We look at immigrants in Ontario, British Columbia, Alberta and Quebec. We hypothesized that not being able to speak either English or French would be associated higher mortality, and that those who speak only English in Quebec would have higher mortality compared to those who speak only English in the other provinces.

Interaction between first official language and province were not significant- i.e. the relationship between first official language and mortality among immigrants does not vary between these 4 provinces, adjusting for age, sex, marital status, self-reported poor health, and education.

We came together for this hackathon to enrich each others learning 
