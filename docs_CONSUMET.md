# Run Consumet API locally

If you want to run the Consumet API locally (for development or to use a local API endpoint), follow these steps.

## Clone and start the Consumet API
```bash
# Clone the Consumet API repository
git clone https://github.com/consumet/api.consumet.org.git

# Change into the repository directory
cd api.consumet.org

# Install dependencies (npm or yarn)
npm install    # or yarn install

# Start the server
npm start      # or yarn start
```

The server will run locally (by default at http://localhost:3000 or as configured by the Consumet API). Configure your application to use the local server address if you want to point your code to this local instance.

## Optional: helper script
If you prefer, add a small shell script to automate the clone + install steps (see `scripts/setup-consumet.sh`).