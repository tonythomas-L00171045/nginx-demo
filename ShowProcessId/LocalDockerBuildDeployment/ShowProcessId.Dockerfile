#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
RUN groupadd --non-unique --gid 1001 awesomegroup
RUN useradd --non-unique --system --uid 1001 --gid 1001 foobar
USER 1001
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8000
EXPOSE 8000

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# 1)Copy projects
COPY ["ShowProcessId/ShowProcessId/ShowProcessId.csproj", "ShowProcessId/"]

RUN dotnet restore "/src/ShowProcessId/ShowProcessId.csproj"

# 2)Copy source code
COPY ShowProcessId/ShowProcessId/.  ShowProcessId/

# 3) Build service
WORKDIR "/src/ShowProcessId"
RUN dotnet build "ShowProcessId.csproj" -c Release -o /app/build

# 4) Publish service
FROM build AS publish
RUN dotnet publish "ShowProcessId.csproj" -c Release -o /app/publish

# 5) Copy published content to runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ShowProcessId.dll"]