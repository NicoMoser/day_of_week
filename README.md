# day_of_week

Years ago I found a formula for computing the day of the week given a calendar day, provided by Claus Tøndering on a page now hosted at https://www.tondering.dk/claus/cal/chrweek.php

The equation computes a few precursor expressions, written here using C syntax which assumes integer (truncated) division:

    a = 14 – month/12
    y = year – a
    m = month + 12*a – 2

Then the day of the week on the Julian calendar, d, is:

    d = ( 5 + day + y + y/4 + 31*m/12 ) % 7

While the day of the week on the Gregorian calendar, d, is:

    d = ( day + y + y/4 – y/100 + y/400 + 31*m/12 ) % 7

where 0 means Sunday, 1 is Monday, etc.

I recently came to revisit the formula and wanted to try to make sense of it, especially the 31\*m\/12 part.

The following article https://www.academia.edu/31413474/Algorithm_to_calculate_the_day_of_the_week was the only other place I could find this expression but all it says is "the maximum duration of the month is 31 days and the year consists of 12 months, so the days between year-end and beginning of the month are equal to the integer part of the product of the number of the month m per the fraction of 31/12." I don't see how that follows and wanted to explore it myself.

To convert a year, month, day to a day of the week, we assume a reference day (which will be determined later) and count number of days after that day, then take the remainder, mod 7. All days with the same remainder are on the same day of the week.

To compute the number of days we use that every year has 365 days except leap years that have 366 days. Whether or not a year is a leap year depends on two things - the year and whether or not we're using a Julian or Gregorian calendar. That transition took place at a variety of dates in various places, but we'll only cover one of those dates. After we've accounted for the different years, we need to figure out the position of the day in the year, for example the 48th day of the year, but we will ruthlessly take shortcuts since we really only care about the difference of between two dates (our date of interest and the reference date) up to a multiple of 7.

To make calculations a little simpler, we start our "year" on March 1. That way the occasional extra day is always the last day of the "year" which means computing the day of the year is consistent from "year" to "year."

To make the conversion to March 1 as the first day of the "year," the intermediate variable, a, will have a value of 1 for January and February, and a value of 0 for March through December. This means that y will be the previous year's value for January and February calculations.

The formula for m just shifts the month number so that for March, m is 1, for April m is 2,..., for January m is 11, and for February m is 12. 

To compute the day of the year given a day and month, we have to account for the varying lengths of the months. If every month had a whole number of weeks, this would be easy. Except for February in a non-leap year, every month has a few days left over from a whole number of weeks. Let's call that its excess. For example a month with 31 days has an excess of 3, while a month with 30 days has an excess of 2. February will be considered to always have 28 days - an excess of 0. The leap day will be handled separately as a function of the year with the y/4 - y/100 + y/400 expression.

So starting in March, our excess counts are 3 2 3 2 3 3 2 3 2 3 3 0. Let's look at an example. Suppose we want to figure out the day of the week for July 13 in a given year. We've assumed some reference date and we know how to count days in years, even with leap years, so we just need to compute the number of days from March 1 to July 13, modulo 7.

This would be the number of days of March, April, May, and June, plus 13 minus 1, mod 7. (Why minus one? Because we're including both March 1 and July 13 in our arithmetic - for example, March 2nd is only 1 day after March 1, not 2, so the -1 corrects this.) 

As numbers:

      (31 +     30 +     31     + 30     + 13 - 1) % 7
    = (28 + 3 + 28 + 2 + 28 + 3 + 28 + 2 + 13 - 1) % 7
    = (     3      + 2      + 3      + 2 + 13 - 1) % 7
    = (10 + 13 - 1) % 7
    = 1
    
So July 13th is always 1 day of the week after March 1.

How to think about these expressions? We rewrote the days in the (whole) months March through June as 28 plus their excess, then added up those excesses - the cumulative total of excesses, or 10.

So for dates in July, we would just have to add 10 to the date, subtract one, then take the remainder after dividing by 7. 

Now let's look at the cumulative total of these values, 0 3 5 8 10 13 16 18 21 23 26 29, for March through February. We could simply use these as a lookup table from the value of m in our formula but it turns out that the expression 31\*m\/12 (remember we're oing integer division) exactly captures something close enough to this sequence. For values 1 to 12, the expression evaluates to 2 5 7 10 12 15 18 20 23 25 28 31. You can ponder until the next paragraph the relationship to the cumulative totals.

Notice that the sequence of 31\*m\/12 values are each exactly 2 more than the sequence of cumulative totals. This is perfect - we can always toss a constant in the expression to shift the resulting date value this way or that, and in fact the Julian calendar has a 5 there.

So we see that it works - this expression yields the exact cumulative totals, shifted by 2. But integer division isn't always so friendly especially as the monthly excesses are not in a simple even pattern, say alternating from 2 to 3. So I wrote a little program that tries every ratio from 1\*m\/1, 1\*m\/2, ..., 1\*m\/100, 2\*m\/1, 2\*m\/2, ..., 2\*m\/100, ... 100\*m\/100 and compares the resulting sequence for m going from 1 to 12 with the known working sequence.

It turns out that 31/12 is the fraction with the smallest numerator/denominator but other fractions work as well. Not surprisingly 62/24 and 93/36 work as they are exact multiples of 31/12, but so also does 44/17, 57/22, 70/27, 75/29, 83/32, and 96/37. 

I still don't understand the connection to maximum number of days in a month and months in a year. The units in the expresion would be (days/month)\*day\/(month\/year) which works out to some nonsense like (day\*day)\*(year)\/(month\*month). It's been ages since I dealt with units so the nonsense could be mine. It could be there is something there and the other fractions are just accidents of integer division. What I'll settle for is to use maximum days of a month and months of a year as a heuristic to remember the expression.
