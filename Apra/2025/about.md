
Apra’s sixth annual Data Science Challenge is back — this time with a collaborative twist! Instead of competing individually, participants will work together in teams to solve a pressing real-world problem in nonprofit fundraising analytics.

## This Year’s Challenge: Building portfolios from a new prospect pool

Your fictional organization’s leadership has approved funding for two new fundraiser hires to strengthen the donor pipeline and drive sustained success over the next three to five years. Your team’s challenge is to analyze the data and design a portfolio strategy that will help leadership determine how to allocate these new resources most effectively to support both near-term and long-term fundraising goals. Using the available data, you will recommend and structure two new portfolios, providing a summary of how these portfolios align with leadership’s objectives and ensure the right fundraisers and strategies are in place to maximize donor engagement and long-term impact.
Participants are encouraged to use innovative visualizations; however, sometimes the simplest solutions are the best — use whatever techniques you think would work best for your organization.

## The Challenge details

### Organizational Context
Recently, your organization expanded, attracting a new pool of potential donors. With this expansion, the vice president of advancement has tasked your team with developing data-driven fundraising portfolios for the new prospect pool. This challenge is not just about identifying prospects but about strategically organizing them into portfolios that maximize fundraising efficiency and impact.

### Research Questions
Below are questions you and your team may choose to consider as you work through this challenge. These are only meant to be suggested starting points, and you are encouraged to take your analysis in any direction you see fit.

- What type of portfolios and how many make the most sense?
- Which prospects should be assigned to which portfolio and why?
- Are there prospects that should be set aside from portfolio-building?
- What characteristics define the best prospects in each pool?
- How should fundraisers prioritize outreach to maximize engagement and giving potential?


## Submission Requirements
Submissions will be judged based on communication, design and analytical approach. Submissions will be highlighted throughout the Data Science Now conference, and attendees will have an opportunity to explore each submission in more detail during the poster viewing session. 

Submit your poster summary to speakers@aprahome.org utilizing the attached PPT template and full analysis in whatever format you prefer (PDF, HTML, MS Excel, link to a website, etc.) by Monday, July 14. Please also include if you are attending Data Science Now, taking place August 19 in Baltimore.

**Poster Summary**: Participants will be provided a PowerPoint template to share text highlights and images/tables/graphs related to the analysis. Apra will assign a QR code to each poster for attendees at Data Science Now to learn more and access your full analysis file. The posters will be displayed digitally during the Data Science Now event for attendee viewing and may be used in additional education offerings. 

Full Analysis
Feel free to use whatever format you prefer.

- Excel file
- Dashboard
- PowerPoint
- Written report
- Video recording
- Web application
- Be creative! (TikTok, YouTube, GIFs)



## Data Files and Descriptions

The data sets are designed to mimic actual fundraising data, so they are not perfectly clean. If you encounter any issues or have questions on the data, please email Data Science Committee member Mike Brucek at mikebrucek@gmail.com.

Participants will be provided the data files to utilize for this challenge beginning in June. The data is meant to replicate data found in the real world and may contain missing or otherwise “messy” information. Getting the data into a usable format for your presentation is part of the challenge!

**Apra Constituent Data (.csv)**
This table contains 1 row for every constituent, as well as any attributes of constituents that can be provided at the constituent level. This table will join with all other tables via "CONSTITUENT_ID".

**Apra Gift Transactions Data (.csv)**
A transaction log of all giving events from every prospect in the data set who has ever made a gift. This file will join back to the constituent file and other files via "CONSTITUENT_ID"

**Apra Interactions Data (.csv)**
This is a complete listing of every interaction that the fictitious database contains. This table will join with all other tables via "CONSTITUENT_ID"

**Apra Video Email Data**
This table contains information on every video email delivered. It is designed to mimic an external data source that can be used alongside CRM data. As such, these will not be found in the CRM Interaction data. This is new information.  This table will join with all other tables via "CONSTITUENT_ID"