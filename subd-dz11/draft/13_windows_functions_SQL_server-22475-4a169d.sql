
  select top 1000 sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId),
  sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId ORDER BY invoiceLines.InvoiceLineId),
  invoices.*, invoiceLines.*
  from [Sales].[Invoices] AS invoices
	join [Sales].[InvoiceLines] as invoiceLines
		ON invoiceLines.InvoiceID = invoices.InvoiceId;

  select top 1000 sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId),
  sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId ORDER BY invoiceLines.InvoiceLineId),
  invoiceLines.ExtendedPrice, invoices.CustomerId, invoiceLines.InvoiceLineId,
  invoices.*, invoiceLines.*
  from [Sales].[Invoices] AS invoices
	join [Sales].[InvoiceLines] as invoiceLines
		ON invoiceLines.InvoiceID = invoices.InvoiceId
  order by invoices.InvoiceID, invoices.CustomerId, invoiceLines.InvoiceLineId;

  select top 1000 sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId),
  sum(invoiceLines.ExtendedPrice) OVER (Partition by invoices.CustomerId ORDER BY invoiceLines.InvoiceLineId),
  invoiceLines.ExtendedPrice, invoices.CustomerId, invoiceLines.InvoiceLineId,
  invoices.*, invoiceLines.*
  from [Sales].[Invoices] AS invoices
	join [Sales].[InvoiceLines] as invoiceLines
		ON invoiceLines.InvoiceID = invoices.InvoiceId
  order by invoices.InvoiceID desc;

  select lag(ExtendedPrice,2) over (ORDER BY InvoiceId),
	lag(ExtendedPrice) over (ORDER BY InvoiceId),
	ExtendedPrice,
	*
  from [Sales].[InvoiceLines];

  select lag(ExtendedPrice,2) over (ORDER BY InvoiceId) as lag_2_offset,
	lag(ExtendedPrice) over (ORDER BY InvoiceId) as lag,
	SUM(ExtendedPrice) over (PARTITION BY InvoiceId ORDER BY InvoiceId) as summ,
	SUM(ExtendedPrice) over (PARTITION BY InvoiceId ORDER BY InvoiceId ROWS UNBOUNDED PRECEDING) as summ_unbound,
	ExtendedPrice,
	*
  from [Sales].[InvoiceLines];
