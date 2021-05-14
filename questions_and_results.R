
bodyQuestions <- c(
  "I don’t regularly get at least seven to eight hours of sleep, and I often wake up feeling tired.",
  "I frequently skip breakfast, or I settle for something that isn’t nutritious.",
  "I don’t work out enough (meaning cardiovascular training at least three times a week and strength training at least once a week).",
  "I don’t take regular breaks during the day to truly renew and recharge, or I often eat lunch at my desk, if I eat it at all.")
mindQuestions <- c(
  "I have difficulty focusing on one thing at a time, and I am easily distracted during the day, especially by e-mail.",
  "I spend much of my day reacting to immediate crises and demands rather than focusing on activities with longer-term value and high leverage.",
  "I don’t take enough time for reflection, strategizing, and creative thinking.",
  "I work in the evenings or on weekends, and I almost never take an e-mail–free vacation."
)
emotionsQuestions <- c(
  "I frequently find myself feeling irritable, impatient, or anxious at work, especially when work is demanding.",
  "I don’t have enough time with my family and loved ones, and when I’m with them, I’m not always really with them.",
  "I have too little time for the activities that I most deeply enjoy.",
  "I don’t stop frequently enough to express my appreciation to others or to savor my accomplishments and blessings."
)
spiritQuestions <- c(
  "I don’t spend enough time at work doing what I do best and enjoy most.",
  "There are significant gaps between what I say is most important to me in my life and how I actually allocate my time and energy.",
  "My decisions at work are more often influenced by external demands than by a strong, clear sense of my own purpose.",
  "I don’t invest enough time and energy in making a positive difference to others or to the world."
)

resultsTitles <- c("Congratulations! You’re an energy management master.", "You're doing great, here's how you can improve", "There is significant room for improvement", "Energy crisis imminent! Immediate action needed!")
recommendations <- c("Teach others to manage their energy well. The world desperately needs more energy management evangelists, especially with ubiquitous screens and constant distractions in the information age. Send this quiz to a colleague, friend, or loved one who might be headed for an energy crisis.",
                     "Keep it up! You may enjoy reading the HBR essay and perhaps reading 'The Power of Full Engagement' book by Jim Loehr and Tony Schwartz.",
                     "You may want to read 'The Power of Full Engagement' and make room for changes in your life to find balance in the four areas of Body, Mind, Emotions, and Spirit.",
                     "You should make restoring a healthy energy balance your top priority. Consider reading  'The Power of Full Engagement' by Jim Loehr and Tony Schwartz.")
totalScoreGuide <- c(
  "Excellent energy management skills",
  "Reasonable energy management skills",
  "Significant energy management deficits",
  "A full-fledged energy management crisis")
totalScoreGuideThresholds <- c(4, 7, 11, 1000000)

categoryScoreGuide <- c(
  "Excellent energy management skills",
  "Strong energy management skills",
  "Significant deficits",
  "Poor energy management, skills",
  "A full-fledged energy crisis")

categories <- c("Body", "Mind", "Emotions", "Spirit")
