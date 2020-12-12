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

To convert a year, month, day to a day of the week, we assume a reference day (which will be determined later) and count number of days after that day, then take the remainder, mod 7. All days with the same remainder are on the same day of the week.

To compute the number of days we use that every year has 365 days except leap years that have 366 days. Whether or not a year is a leap year depends on two things - the year and whether or not we're using a Julian or Gregorian calendar. That transition took place at a variety of dates in various places, but we'll only cover one of those dates. After we've accounted for the different years, we need to figure out the position of the day in the year, for example the 48th day of the year, but we will ruthlessly take shortcuts since we really only care about the difference of between two dates (our date of interest and the reference date) up to a multiple of 7.

To make calculations a little simpler, we start our "year" on March 1. That way the occasional extra day is always the last day of the "year" which means computing the day of the year is consistent from "year" to "year."

To make the conversion to March 1 as the first day of the "year," the intermediate variable, a, will have a value of 1 for January and February, and a value of 0 for March through December. This means that y will be the previous year's value for January and February calculations.

The formula for m just shifts the month number so that for March, m is 1, for April m is 2,..., for January m is 11, and for February m is 12. 

To compute the day of the year given a day and month, we have to account for the varying lengths of the months. If every month had a whole number of weeks, this would be easy. Except for February in a non-leap year, every month has a few days left over from a whole number of weeks. Let's call that its excess. For example a month with 31 days has an excess of 3, while a month with 30 days has an excess of 2. February will be considered to always have 28 days - an excess of 0. The leap day will be handled separately as a function of the year with the y/4 - y/100 + y/400 expression.

So starting in March, our excess counts are 3 2 3 2 3 3 2 3 2 3 3 0. Let's look at an example. Suppose we want to figure out the day of the week for July 13 in a given year. We've assumed some reference date and we know how to count days in years, even with leap years, so we just need to compute the number of days from March 1 to July 13, modulo 7.

This would be the number of days of March, April, May, and June, plus 13 minus 1, mod 7. (Why minus one? Because we're including both March 1 and July 13 in our arithmetic - for example, we can think of April 1 as "March 32nd" xxx) 

As numbers:

      (31 +     30 +     31     + 30     + 13 - 1) % 7
    = (28 + 3 + 28 + 2 + 28 + 3 + 28 + 2 + 13 - 1) % 7
    = (     3      + 2      + 3      + 2 + 13 - 1) % 7
    = (10 + 13 - 1) % 7
    = 1

How to think about this? We rewrote the days in the (whole) months March through June as 28 plus their excess, then added up those excesses - the cumulative total of excesses. 

So for dates in July, we would just have to add 10 to the date, subtract one, then take the remainder after dividing by 7. 

And what is the meaning of the 1 at the end? It means that July 13th is 1 day of the week after March 1st. 

We still haven't had to pick a reference date that forces March 1st of a particular year to have a particular day of the week.

But rather than picking a reference date, I'm going to modify the calculation and get the reference date out of that. I'm going to modify the cumulative 


I mentioned earlier that we would be using a reference date and I'm going to partially play that card now. We're going to look at the cumulative total of these values

Now let's look at the cumulative total of these values, 2 5 8 10 13 16 18 21 23 26 29. Why are the cumulative totals important? 


Suppose we want to figure out the day of the week for July 13 in a given year. We've assumed some reference date and we know how to count days in years, even with leap years, so we just need to compute the number of days from March 1 to July 13, modulo 7.

This would be the number of days of March, April, May, and June, plus 13, mod 7. As numbers:

      (31 +     30 +     31     + 30     + 13) % 7
    = (28 + 3 + 28 + 2 + 28 + 3 + 28 + 2 + 13) % 7
    = (     3      + 2      + 3      + 2 + 13) % 7
    = (10 + 13) % 7
    = 2

How to think about this? We rewrote the days in the (whole) months as 28 plus their excess, then added up those excesses - the cumulative total of excesses. 

Note that the cumulative excess as a function of m, the month number starting at 1 for March is pretty close to linear - the increase from month to month is always 2 or 3. The clever trick here is that we can use a linear expression in terms of m to get just over the target value and rely on integer division to truncate down to the actual value.
