create procedure [dbo].[ProcessDeadlockMessages]
as
begin
	set nocount on
	set xact_abort on

	declare @DialogHandle uniqueidentifier
	declare @MessageTypeName nvarchar(256)
	declare @MessageBody varbinary(max)
	declare @DeadlockGraph xml

	while 1 = 1
	begin

		begin transaction

		waitfor (
			receive top (1)
				@DialogHandle = [conversation_handle],
				@MessageTypeName = [message_type_name],
				@MessageBody = [message_body]
			from [dbo].[DeadlockNotificationQueue]
		), timeout 5000

		if @@rowcount = 0
		begin
			commit transaction
			break
		end

		begin try

			if @MessageTypeName = N'http://schemas.microsoft.com/SQL/Notifications/EventNotification'
			   and @MessageBody is not null
			begin
				set @DeadlockGraph = convert(xml, @MessageBody)

				insert into [dbo].[DeadlockLog] (
					[DeadlockGraph]
				)
				values (
					@DeadlockGraph
				)
			end

			if @MessageTypeName in (
				N'http://schemas.microsoft.com/SQL/ServiceBroker/Error',
				N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			)
			begin
				end conversation @DialogHandle
			end

			commit transaction

		end try
		begin catch

			if @@trancount > 0
			begin
				rollback transaction
			end

			;throw

		end catch

	end
end
go